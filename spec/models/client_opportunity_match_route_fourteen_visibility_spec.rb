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

  # Marks every step before `pending_key` accepted and `pending_key` pending, bypassing callbacks.
  def current_step!(pending_key)
    keys = route.class.match_steps.keys.map { |k| k.demodulize.underscore }
    keys.take_while { |k| k != pending_key }.each { |k| match.send("#{k}_decision").update_columns(status: 'accepted') }
    match.send("#{pending_key}_decision").update_columns(status: 'pending')
    match.instance_variable_set(:@current_decision, nil)
  end

  before do
    match.shelter_agency_contacts << shelter
    match.hsp_contacts << hsp
    match.housing_subsidy_admin_contacts << hsa
    allow_any_instance_of(Client).to receive(:accessible_by_user?).and_return(false)
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

  it 'reveals the client to HSP, but not HSA, at Eligibility Screening' do
    current_step!('fourteen_eligibility_screening')
    expect(match.show_client_info_to?(hsp)).to be true
    expect(match.show_client_info_to?(hsa)).to be false
  end

  it 'reveals the client to HSA at Subsidy Administrator Screening' do
    current_step!('fourteen_subsidy_admin_screening')
    expect(match.show_client_info_to?(hsa)).to be true
  end

  it 'leaves route thirteen HSA behavior unchanged' do
    thirteen = create :client_opportunity_match, match_route: MatchRoutes::Thirteen.first
    thirteen.housing_subsidy_admin_contacts << hsa
    thirteen.thirteen_client_match_decision.update_columns(status: 'pending')
    expect(thirteen.show_client_info_to?(hsa)).to be false
  end
end
