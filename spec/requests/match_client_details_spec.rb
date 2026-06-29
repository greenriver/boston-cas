###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MatchClientDetails', type: :request do
  let(:user) { create(:user) }
  let(:admin_role) { create(:admin_role) }
  let(:priority) { create(:priority_vispdat_priority) }
  let(:route) { create(:default_route, match_prioritization: priority) }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }

  before do
    user.roles << admin_role
    sign_in user
    allow_any_instance_of(ClientOpportunityMatch).to receive(:show_client_info_to?).and_return(false)
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
  end

  describe 'GET /matches/:match_id/client_details' do
    it 'includes the print footer in ajax modal requests' do
      get match_client_details_path(match), headers: { 'X-Ajax-Modal' => 'true' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('modal-footer')
      expect(response.body).to include('icon-printer')
      expect(response.body).to include('data-bs-title="Printable"')
    end

    it 'does not include the print footer on full-page requests' do
      get match_client_details_path(match)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('icon-printer')
      expect(response.body).not_to include('data-bs-title="Printable"')
    end
  end
end
