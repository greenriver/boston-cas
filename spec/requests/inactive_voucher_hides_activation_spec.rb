###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Activation is hidden when a voucher is unavailable', type: :request do
  let!(:contact) { create :macbeth }
  let!(:user) { create :user, contact: contact }
  let!(:prioritization_scheme) { create :priority_days_homeless }
  let!(:route) do
    route = MatchRoutes::Default.first
    route.update(match_prioritization: prioritization_scheme)
    route
  end
  let!(:match) { create :client_opportunity_match, active: false, match_route: route }
  let!(:project_client) { create :project_client, client_id: match.client.id }
  let(:opportunity) { match.opportunity }
  let(:voucher) { opportunity.voucher }

  before(:each) do
    sign_in user
  end

  describe 'the prioritized clients (opportunity matches) page' do
    let!(:role) do
      create :role,
             can_see_all_alternate_matches: true,
             can_edit_assigned_programs: true,
             can_view_assigned_programs: true,
             can_activate_matches: true
    end

    before(:each) do
      EntityViewPermission.create(entity: match.program, agency: user.agency, editable: true)
      user.roles << role
    end

    context 'when the voucher is available' do
      it 'shows the activate match controls' do
        get opportunity_matches_path(opportunity_id: opportunity.id)

        expect(response.body).to include('Activate Match')
      end
    end

    context 'when the voucher is not available' do
      before(:each) { voucher.update!(available: false) }

      it 'hides the activate match controls' do
        get opportunity_matches_path(opportunity_id: opportunity.id)

        expect(response.body).to_not include('Activate Match')
      end

      it 'refuses to activate a match via the controller' do
        expect do
          patch opportunity_match_path(opportunity, match.client.id)
        end.to_not(change { opportunity.active_matches.count })

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'the vouchers index page' do
    let!(:role) do
      create :role,
             can_view_vouchers: true,
             can_view_assigned_programs: true
    end

    before(:each) do
      EntityViewPermission.create(entity: match.program, agency: user.agency, editable: true)
      user.roles << role
    end

    context 'when the voucher is available' do
      it 'shows the Prioritized Clients link' do
        get program_sub_program_vouchers_path(program_id: match.program.id, sub_program_id: match.sub_program.id)

        expect(response.body).to include('Prioritized Clients')
      end
    end

    context 'when the voucher is not available' do
      before(:each) { voucher.update!(available: false) }

      it 'hides the Prioritized Clients link' do
        get program_sub_program_vouchers_path(program_id: match.program.id, sub_program_id: match.sub_program.id)

        expect(response.body).to_not include('Prioritized Clients')
      end
    end
  end
end
