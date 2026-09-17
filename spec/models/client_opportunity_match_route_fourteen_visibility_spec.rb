###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientOpportunityMatch, 'route fourteen client visibility', type: :model do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:shelter) { create :contact }
  let(:hsp) { create :contact }
  let(:hsa) { create :contact }
  let(:reason) { create :match_decision_reason }
  let!(:non_hmis_data_source) { create :data_source, :deidentified }

  # Marks every step before `pending_key` accepted and `pending_key` pending, bypassing callbacks.
  def current_step!(pending_key)
    keys = route.class.match_steps_for_reporting.keys.map { |k| k.demodulize.underscore }
    keys.take_while { |k| k != pending_key }.reject { |k| k.end_with?('_decline') }.each { |k| match.send("#{k}_decision").update_columns(status: 'accepted') }
    match.send("#{pending_key}_decision").update_columns(status: 'pending')
    match.instance_variable_set(:@current_decision, nil)
  end

  def run!(decision, attrs)
    decision.update!(attrs)
    decision.run_status_callback!
  end

  before do
    match.shelter_agency_contacts << shelter
    match.hsp_contacts << hsp
    match.housing_subsidy_admin_contacts << hsa
  end

  it 'hides the client from everyone at Initiate Match' do
    current_step!('fourteen_initiate_match')
    expect([shelter, hsp, hsa].map { |c| match.show_client_info_to?(c) }).to all(be false)
  end

  it 'reveals the client to the shelter agency, but not HSP or HSA, at Acknowledge Match' do
    current_step!('fourteen_match_acknowledgement')
    expect(match.show_client_info_to?(shelter)).to be true
    expect(match.show_client_info_to?(hsp)).to be false
    expect(match.show_client_info_to?(hsa)).to be false
  end

  it 'hides the client from HSA at Acknowledge Match even when the route does not expect an ROI' do
    route.update!(expects_roi: false)
    current_step!('fourteen_match_acknowledgement')
    expect(match.client.has_full_housing_release?(match.match_route)).to be true
    expect(match.show_client_info_to?(hsa)).to be false
  ensure
    route.update!(expects_roi: true)
  end

  it 'reveals the client to HSP, but not HSA, at Eligibility Screening' do
    current_step!('fourteen_eligibility_screening')
    expect(match.show_client_info_to?(hsp)).to be true
    expect(match.show_client_info_to?(hsa)).to be false
  end

  it 'keeps the client visible to HSP, but not HSA, while DND reviews the Eligibility Screening decline' do
    current_step!('fourteen_eligibility_screening_decline')
    expect(match.show_client_info_to?(hsp)).to be true
    expect(match.show_client_info_to?(hsa)).to be false
  end

  it 'reveals the client to HSA at Subsidy Administrator Screening' do
    current_step!('fourteen_subsidy_admin_screening')
    expect(match.show_client_info_to?(hsa)).to be true
  end

  it 'keeps the client visible to shelter, HSP, and HSA at Offer Unit' do
    current_step!('fourteen_offer_unit')
    expect([shelter, hsp, hsa].map { |c| match.show_client_info_to?(c) }).to all(be true)
  end

  describe 'closed matches' do
    it 'hides the client from HSP and HSA when canceled at Initiate Match' do
      match.fourteen_initiate_match_decision.initialize_decision!(send_notifications: false)
      run!(match.fourteen_initiate_match_decision, status: 'canceled', administrative_cancel_reason: reason)

      expect(match.reload).to have_attributes(closed: true, closed_reason: 'canceled')
      expect(match.show_client_info_to?(hsp)).to be false
      expect(match.show_client_info_to?(hsa)).to be false
    end

    it 'keeps the client visible to HSP, but not HSA, when rejected at Eligibility Screening' do
      current_step!('fourteen_eligibility_screening')
      run!(match.fourteen_eligibility_screening_decision, status: 'declined', decline_reason: reason)
      run!(match.fourteen_eligibility_screening_decline_decision, status: 'decline_confirmed')

      expect(match.reload).to have_attributes(closed: true, closed_reason: 'rejected')
      expect(match.show_client_info_to?(hsp)).to be true
      expect(match.show_client_info_to?(hsa)).to be false
    end
  end

  it 'leaves route thirteen HSA behavior unchanged' do
    thirteen = create :client_opportunity_match, match_route: MatchRoutes::Thirteen.first
    thirteen.housing_subsidy_admin_contacts << hsa
    thirteen.thirteen_client_match_decision.update_columns(status: 'pending')
    expect(thirteen.show_client_info_to?(hsa)).to be false
  end
end
