###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match Route Fourteen decision flow', type: :model do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:reason) { create :match_decision_reason }

  # Each forward step validates a contact of its own actor type, and decline/cancel
  # statuses each require a reason.
  def advance(decision, status)
    attrs = { status: status }
    attrs[:decline_reason] = reason if status == 'declined'
    attrs[:administrative_cancel_reason] = reason if status == 'canceled'
    decision.update!(attrs)
    decision.run_status_callback!
  end

  before do
    match.shelter_agency_contacts << create(:contact)
    match.hsp_contacts << create(:contact)
    match.housing_subsidy_admin_contacts << create(:contact)
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.fourteen_initiate_match_decision.initialize_decision!(send_notifications: false)
  end

  it 'walks every forward step to success' do
    advance(match.fourteen_initiate_match_decision, 'accepted')
    expect(match.fourteen_match_acknowledgement_decision.reload.status).to eq('pending')
    advance(match.fourteen_match_acknowledgement_decision, 'acknowledged')
    expect(match.fourteen_client_review_decision.reload.status).to eq('pending')
    advance(match.fourteen_client_review_decision, 'accepted')
    expect(match.fourteen_eligibility_screening_decision.reload.status).to eq('pending')
    advance(match.fourteen_eligibility_screening_decision, 'accepted')
    expect(match.fourteen_subsidy_admin_screening_decision.reload.status).to eq('pending')
    advance(match.fourteen_subsidy_admin_screening_decision, 'accepted')
    expect(match.fourteen_offer_unit_decision.reload.status).to eq('pending')
    advance(match.fourteen_offer_unit_decision, 'accepted')
    expect(match.fourteen_confirm_match_success_decision.reload.status).to eq('pending')
    advance(match.fourteen_confirm_match_success_decision, 'confirmed')
    expect(match.reload).to have_attributes(closed: true, closed_reason: 'success')
  end

  describe 'declining Eligibility Screening' do
    before do
      match.fourteen_eligibility_screening_decision.initialize_decision!(send_notifications: false)
      advance(match.fourteen_eligibility_screening_decision, 'declined')
    end

    it 'hands the match to the DND review-decline step' do
      expect(match.fourteen_eligibility_screening_decline_decision.reload.status).to eq('pending')
      expect(route.status_declined?(match)).to be true
    end

    it 'override skips the declined step and starts Subsidy Administrator Screening' do
      advance(match.fourteen_eligibility_screening_decline_decision, 'decline_overridden')
      expect(match.fourteen_eligibility_screening_decision.reload.status).to eq('skipped')
      expect(match.fourteen_subsidy_admin_screening_decision.reload.status).to eq('pending')
      expect(route.status_declined?(match)).to be false
    end

    it 'override-and-return reopens Eligibility Screening' do
      advance(match.fourteen_eligibility_screening_decline_decision, 'decline_overridden_returned')
      expect(match.fourteen_eligibility_screening_decision.reload.status).to eq('pending')
      expect(match.fourteen_eligibility_screening_decline_decision.reload.status).to be_nil
    end

    it 'confirming the decline rejects the match' do
      advance(match.fourteen_eligibility_screening_decline_decision, 'decline_confirmed')
      expect(match.reload).to have_attributes(closed: true, closed_reason: 'rejected')
    end
  end

  describe 'Initiate Match required contacts' do
    {
      shelter_agency_contacts: 'Shelter Agency Fourteen',
      housing_subsidy_admin_contacts: 'HSA Fourteen',
      hsp_contacts: 'Housing Search Provider Fourteen',
    }.each do |contact_type, label|
      it "cannot be accepted without a #{label} contact" do
        match.send(contact_type).clear
        decision = match.fourteen_initiate_match_decision
        decision.status = 'accepted'

        expect(decision).not_to be_valid
        expect(decision.errors[:match_contacts].join).to include(label)
      end
    end

    it 'can be accepted once all three contact types are present' do
      decision = match.fourteen_initiate_match_decision
      decision.status = 'accepted'

      expect(decision).to be_valid
    end
  end

  describe 'Confirm Match Success move-in date' do
    let(:decision) { match.fourteen_confirm_match_success_decision }

    before { decision.initialize_decision!(send_notifications: false) }

    context 'when the route records move-in dates' do
      # The decision caches its route through the match, so reload after flipping the flag.
      before do
        route.update!(show_move_in_date: true)
        decision.reload
      end
      after { route.update!(show_move_in_date: false) }

      it 'cannot be confirmed without a move-in date' do
        decision.status = 'confirmed'

        expect(decision).not_to be_valid
        expect(decision.errors[:client_move_in_date]).to eq(['must be filled in'])
      end

      it 'stores the move-in date on the decision when confirmed' do
        decision.update!(status: 'confirmed', client_move_in_date: Date.new(2026, 10, 1))
        decision.run_status_callback!

        expect(decision.reload.client_move_in_date.to_date).to eq(Date.new(2026, 10, 1))
        expect(match.reload.closed_reason).to eq('success')
      end

      it 'accepts the move-in date through the permitted params' do
        expect(decision.permitted_params).to include(:client_move_in_date)
      end
    end

    it 'can be confirmed without a move-in date when the route does not record one' do
      decision.status = 'confirmed'

      expect(decision).to be_valid
    end
  end

  it 'canceling Initiate Match closes the match as canceled' do
    advance(match.fourteen_initiate_match_decision, 'canceled')
    expect(match.reload).to have_attributes(closed: true, closed_reason: 'canceled')
  end

  it 'is stallable on steps 4-7 only' do
    stallable = route.class.match_steps.keys.select { |name| name.constantize.new.stallable? }
    expect(stallable).to contain_exactly(
      'MatchDecisions::Fourteen::FourteenEligibilityScreening',
      'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening',
      'MatchDecisions::Fourteen::FourteenOfferUnit',
      'MatchDecisions::Fourteen::FourteenConfirmMatchSuccess',
    )
  end

  it 'offers stalled responses on every stallable step' do
    StalledResponse.ensure_all
    ['FourteenEligibilityScreening', 'FourteenSubsidyAdminScreening', 'FourteenOfferUnit', 'FourteenConfirmMatchSuccess'].each do |name|
      expect(StalledResponse.for_decision("MatchDecisions::Fourteen::#{name}").where.not(decision_type: 'DEFAULT')).to exist, "no responses for #{name}"
    end
  end

  it 'accepts a decline reason on steps 2-6 only' do
    declinable = route.class.match_steps.keys.select { |name| name.constantize.include?(MatchDecisions::AcceptsDeclineReason) }
    expect(declinable).to contain_exactly(
      'MatchDecisions::Fourteen::FourteenMatchAcknowledgement',
      'MatchDecisions::Fourteen::FourteenClientReview',
      'MatchDecisions::Fourteen::FourteenEligibilityScreening',
      'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening',
      'MatchDecisions::Fourteen::FourteenOfferUnit',
    )
  end
end
