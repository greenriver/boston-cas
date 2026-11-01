###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Submitting an invalid decline', type: :request do
  let(:shelter_user) { create(:user) }
  let(:match) { create(:client_opportunity_match) }
  let(:decision) { match.match_recommendation_shelter_agency_decision }
  let(:reason) { create(:match_decision_reason, name: 'Needs Explanation') }

  before do
    sign_in shelter_user
    match.shelter_agency_contacts << shelter_user.contact
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    create(
      :match_decision_reason_assignment,
      route: match.match_route,
      decision_type: decision.class.name,
      kind: 'decline',
      match_decision_reason: reason,
      requires_explanation: true,
    )
    decision.initialize_decision!(send_notifications: false)
  end

  def submit_decline(explanation:)
    patch match_decision_path(match, 'match_recommendation_shelter_agency'), params: {
      decision: {
        status: 'declined',
        decline_reason_id: reason.id,
        decline_reason_other_explanation: explanation,
      },
    }
  end

  def status_badge_text
    Nokogiri::HTML(response.body).at_css('.c-tag .c-tag__content span').text.strip
  end

  it 'shows the persisted In Progress status, not the unsaved decline, when the explanation is missing' do
    submit_decline(explanation: '')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Decline reason details must be provided for the selection of any decline reason')
    expect(status_badge_text).to eq('In Progress')
    expect(decision.reload.status).to eq('pending')
  end

  it 'keeps the selected decline reason on the re-rendered form' do
    submit_decline(explanation: '')

    selected = Nokogiri::HTML(response.body).at_css("input[name='decision[decline_reason_id][]'][checked]")
    expect(selected['value']).to eq(reason.id.to_s)
  end

  it 'shows Declined once a valid decline is saved' do
    submit_decline(explanation: 'Client moved out of state')
    follow_redirect!

    expect(status_badge_text).to eq('Declined')
    expect(decision.reload.status).to eq('declined')
  end
end
