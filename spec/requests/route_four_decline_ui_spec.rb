###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Route Four decline UI', type: :request do
  let(:hsa_user) { create(:user) }
  let(:priority) { create(:priority_vispdat_priority) }
  let(:route) { MatchRoutes::Four.first || create(:route_four) }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }

  before do
    sign_in hsa_user
    match.housing_subsidy_admin_contacts << hsa_user.contact
    allow_any_instance_of(ClientOpportunityMatch).to receive(:show_client_info_to?).and_return(false)
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
  end

  describe 'ScheduleCriminalHearingHousingSubsidyAdmin' do
    before do
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.initialize_decision!(send_notifications: false)
    end

    it 'renders a Decline tab for the HSA contact' do
      get match_decision_path(match, 'four_schedule_criminal_hearing_housing_subsidy_admin')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Decline')
    end
  end

  describe 'RecordClientHousedDateHousingSubsidyAdministrator' do
    before do
      match.four_record_client_housed_date_housing_subsidy_administrator_decision.initialize_decision!(send_notifications: false)
    end

    it 'renders a Decline tab for the HSA contact' do
      get match_decision_path(match, 'four_record_client_housed_date_housing_subsidy_administrator')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Decline')
    end
  end

  describe 'ConfirmScheduleCriminalHearingDeclineDndStaff' do
    let(:dnd_user) { create(:user) }
    let(:admin_role) { create(:admin_role) }

    before do
      dnd_user.roles << admin_role
      sign_in dnd_user
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.initialize_decision!(send_notifications: false)
      match.four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision.initialize_decision!(send_notifications: false)
    end

    it 'renders the DND review-decline page' do
      get match_decision_path(match, 'four_confirm_schedule_criminal_hearing_decline_dnd_staff')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Review Decline')
    end
  end

  describe 'ConfirmRecordClientHousedDateDeclineDndStaff' do
    let(:dnd_user) { create(:user) }
    let(:admin_role) { create(:admin_role) }

    before do
      dnd_user.roles << admin_role
      sign_in dnd_user
      match.four_record_client_housed_date_housing_subsidy_administrator_decision.initialize_decision!(send_notifications: false)
      match.four_confirm_record_client_housed_date_decline_dnd_staff_decision.initialize_decision!(send_notifications: false)
    end

    it 'renders the DND review-decline page' do
      get match_decision_path(match, 'four_confirm_record_client_housed_date_decline_dnd_staff')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Review Decline')
    end
  end
end
