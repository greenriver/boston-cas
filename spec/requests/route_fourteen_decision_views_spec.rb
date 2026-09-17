###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Route Fourteen decision views', type: :request do
  let(:dnd_user) { create(:user) }
  let(:user) { dnd_user }
  let(:route) { MatchRoutes::Fourteen.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }

  # Only the decline tab's submit button carries this exact value; the shelter-decline
  # variant submits "shelter_declined".
  let(:decline_submit_marker) { 'data-submit-param-value="declined"' }

  let!(:non_hmis_data_source) { create(:data_source, :deidentified) }

  before do
    dnd_user.roles << create(:admin_role)
    sign_in user
  end

  describe 'as a contact of another actor type' do
    let(:hsp) { create(:contact) }
    let(:user) { create(:user, contact: hsp) }

    before do
      match.hsp_contacts << hsp
      user.roles << create(:role, can_participate_in_matches: true)
      match.fourteen_subsidy_admin_screening_decision.initialize_decision!(send_notifications: false)
    end

    it 'redirects away from the step with an alert' do
      get match_decision_path(match, 'fourteen_subsidy_admin_screening')
      expect(response).to redirect_to(match_path(match))
      expect(flash[:alert]).to eq('Sorry, you are not authorized to access that.')
    end
  end

  MatchRoutes::Fourteen.match_steps_for_reporting.each_key do |decision_class|
    key = decision_class.demodulize.underscore

    it "renders #{decision_class}" do
      match.send("#{key}_decision").initialize_decision!(send_notifications: false)
      get match_decision_path(match, key)
      expect(response).to have_http_status(:ok)
    end
  end

  it 'renders the match contacts picker on Initiate Match, marking only the required contact types' do
    match.fourteen_initiate_match_decision.initialize_decision!(send_notifications: false)
    get match_decision_path(match, 'fourteen_initiate_match')
    expect(response.body).to include('Add / Review Contacts for Match')
    required_mark = '<abbr title="required">*</abbr>'
    expect(response.body).to include("Shelter Agency Fourteen Contacts #{required_mark}")
    expect(response.body).to include("HSA Fourteen Contacts #{required_mark}")
    expect(response.body).to include("Housing Search Provider Fourteen Contacts #{required_mark}")
    expect(response.body).not_to include("CoC Fourteen Contacts #{required_mark}")
    expect(response.body).not_to include("Stabilization Service Providers Fourteen Contacts #{required_mark}")
  end

  it 'requires the shelter agency agreement modal to accept Client Review' do
    match.fourteen_client_review_decision.initialize_decision!(send_notifications: false)
    get match_decision_path(match, 'fourteen_client_review')
    expect(response.body).to include('jNeedsToAgree')
    expect(response.body).to include('shelter-agency-modal')
  end

  describe 'Confirm Match Success move-in date field' do
    before { match.fourteen_confirm_match_success_decision.initialize_decision!(send_notifications: false) }

    it 'is shown when the route records move-in dates' do
      route.update!(show_move_in_date: true)
      get match_decision_path(match, 'fourteen_confirm_match_success')
      expect(response.body).to include('decision_client_move_in_date')
    ensure
      route.update!(show_move_in_date: false)
    end

    it 'is hidden when the route does not record move-in dates' do
      get match_decision_path(match, 'fourteen_confirm_match_success')
      expect(response.body).not_to include('decision_client_move_in_date')
    end
  end

  it 'offers Decline on Eligibility Screening' do
    match.fourteen_eligibility_screening_decision.initialize_decision!(send_notifications: false)
    get match_decision_path(match, 'fourteen_eligibility_screening')
    expect(response.body).to include(decline_submit_marker)
  end

  it 'does not offer Decline on Initiate Match' do
    match.fourteen_initiate_match_decision.initialize_decision!(send_notifications: false)
    get match_decision_path(match, 'fourteen_initiate_match')
    expect(response.body).not_to include(decline_submit_marker)
  end
end
