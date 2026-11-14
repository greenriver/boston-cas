###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Decision status submitted by the acting contact', type: :request do
  let(:route) { MatchRoutes::Default.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:participant_role) { create(:shelter_role) }
  let(:hsa_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:shelter_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:admin_user) { create(:user).tap { |u| u.roles << create(:admin_role) } }
  let(:cancel_reason) { MatchDecisionReasons::AdministrativeCancel.create!(name: 'Vacancy filled by other client') }
  let(:decline_reason) { create(:hsa_decline_reason) }
  let(:decision) { match.approve_match_housing_subsidy_admin_decision }
  let(:previous_decision) { decision.previous_step }
  let(:next_decision) { decision.next_step }
  let(:decision_path) { match_decision_path(match, 'approve_match_housing_subsidy_admin') }

  before do
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.housing_subsidy_admin_contacts << hsa_user.contact
    match.shelter_agency_contacts << shelter_user.contact
    previous_decision.update!(status: 'no_hearing')
    decision.initialize_decision!(send_notifications: false)
  end

  def submit(decision_attributes)
    patch decision_path, params: { decision: decision_attributes }
  end

  context 'when the HSA cannot reject matches' do
    before { sign_in hsa_user }

    it 'does not cancel the match' do
      submit(status: 'canceled', administrative_cancel_reason_id: cancel_reason.id)

      expect(response).to redirect_to(match_path(match))
      expect(match.reload.closed).to be(false)
      expect(decision.reload.status).to eq('pending')
    end

    it 'does not step the match back' do
      submit(status: 'back')

      expect(decision.reload.status).to eq('pending')
      expect(previous_decision.reload.status).to eq('no_hearing')
    end

    it 'does not disable the opportunity' do
      submit(status: 'pending', administrative_cancel_reason_id: cancel_reason.id, disable_opportunity: '1')

      expect(opportunity.reload.available).to be(true)
      expect(voucher.reload.available).to be(true)
    end

    it 'accepts the match' do
      submit(status: 'accepted')

      expect(decision.reload.status).to eq('accepted')
      expect(next_decision.reload.status).to eq('pending')
    end

    it 'refuses a cancel with no reason as unauthorized' do
      submit(status: 'canceled')

      expect(response).to redirect_to(match_path(match))
      expect(flash[:alert]).to eq('Sorry, you are not authorized to access that.')
      expect(decision.reload.status).to eq('pending')
    end

    it 'does not record a shelter decline' do
      submit(status: 'shelter_declined', decline_reason_id: decline_reason.id, decline_reason_other_explanation: 'Client moved')

      expect(flash[:alert]).to eq('Sorry, you are not authorized to access that.')
      expect(decision.reload.status).to eq('pending')
      expect(match.confirm_shelter_decline_of_hsa_approval_decision.reload.status).to be_nil
    end
  end

  context 'when a shelter agency contact acts on the HSA step' do
    before { sign_in shelter_user }

    it 'does not cancel the match' do
      submit(status: 'canceled', administrative_cancel_reason_id: cancel_reason.id)

      expect(match.reload.closed).to be(false)
      expect(decision.reload.status).to eq('pending')
    end

    it 'does not step the match back' do
      submit(status: 'back')

      expect(decision.reload.status).to eq('pending')
      expect(previous_decision.reload.status).to eq('no_hearing')
    end

    it 'does not accept the match' do
      submit(status: 'accepted')

      expect(decision.reload.status).to eq('pending')
      expect(next_decision.reload.status).to be_nil
    end

    it 'records a shelter decline' do
      submit(status: 'shelter_declined', decline_reason_id: decline_reason.id, decline_reason_other_explanation: 'Client moved')

      expect(decision.reload.decline_reason).to eq(decline_reason)
      expect(match.confirm_shelter_decline_of_hsa_approval_decision.reload.status).to eq('pending')
    end

    it 'refuses a cancel reason sent with a shelter decline' do
      submit(
        status: 'shelter_declined',
        decline_reason_id: decline_reason.id,
        decline_reason_other_explanation: 'Client moved',
        administrative_cancel_reason_id: cancel_reason.id,
      )

      expect(flash[:error]).to eq('Sorry, if a cancel reason is specified, you can only cancel this match recommendation.')
      decision.reload
      expect(decision.administrative_cancel_reason_id).to be_nil
      expect(decision.status).to eq('pending')
    end
  end

  context 'when the user can reject matches' do
    before { sign_in admin_user }

    it 'cancels the match' do
      submit(status: 'canceled', administrative_cancel_reason_id: cancel_reason.id)

      match.reload
      expect(match.closed).to be(true)
      expect(match.closed_reason).to eq('canceled')
    end

    it 'steps the match back' do
      submit(status: 'back')

      expect(decision.reload.status).to be_nil
      expect(previous_decision.reload.status).to eq('pending')
    end
  end
end

RSpec.describe 'Acknowledging a decision through the decision form', type: :request do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:shelter_user) { create(:user).tap { |u| u.roles << create(:shelter_role) } }
  let(:acknowledgement) { match.fourteen_match_acknowledgement_decision }
  let(:client_review) { match.fourteen_client_review_decision }

  let!(:non_hmis_data_source) { create(:data_source, :deidentified) }

  before do
    match.shelter_agency_contacts << shelter_user.contact
    acknowledgement.initialize_decision!(send_notifications: false)
    sign_in shelter_user
  end

  def acknowledge
    patch match_decision_path(match, 'fourteen_match_acknowledgement'), params: { decision: { status: 'acknowledged' } }
  end

  it 'acknowledges a pending step and opens the next step' do
    acknowledge

    expect(acknowledgement.reload.status).to eq('acknowledged')
    expect(client_review.reload.status).to eq('pending')
  end

  it 'does not reopen the next step when the step is already acknowledged' do
    acknowledgement.update!(status: 'acknowledged')
    client_review.update!(status: 'accepted')

    acknowledge

    expect(response).to redirect_to(match_path(match))
    expect(flash[:alert]).to eq('Sorry, you are not authorized to access that.')
    expect(client_review.reload.status).to eq('accepted')
  end
end
