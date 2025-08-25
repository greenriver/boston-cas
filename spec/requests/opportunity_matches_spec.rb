###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpportunityMatchesController, type: :request do
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
  let!(:role) { create :role, can_see_alternate_matches: true, can_edit_assigned_programs: false, can_activate_matches: false, can_view_assigned_programs: true }

  before(:each) do
    sign_in user
  end

  describe 'GET index' do
    it "can't access without permission" do
      get opportunity_matches_path(opportunity_id: match.opportunity.id)
      expect(response.status).to eq 302
    end

    describe 'with assigned agency' do
      before(:each) do
        EntityViewPermission.create(entity: match.program, agency: user.agency, editable: true)
      end

      it "can't access without permission" do
        get opportunity_matches_path(opportunity_id: match.opportunity.id)
        expect(response.status).to eq 302
      end

      it 'cannot access with only permission to activate matches' do
        role.update(can_activate_matches: true)
        user.roles << role
        get opportunity_matches_path(opportunity_id: match.opportunity.id)
        expect(response.status).to eq 302
      end

      # You only see alternate clients if you can see ALL alternate clients
      # OR if you can see alternate clients AND you are the in the initial contact types for this route on this match (and the match is active)
      # OR if you are a default contact on the sub-program of the type that receives initial contact
      describe 'You only see alternate clients if you can see ALL alternate clients' do
        before do
          role.update(can_edit_assigned_programs: true, can_see_all_alternate_matches: true)
          user.roles << role
        end
        it 'can access the page' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.status).to eq 200
        end

        it 'page does not include activate match link' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.body).to_not include('Activate Matches')
        end

        describe 'when client has can_activate_matches' do
          before do
            role.update(can_activate_matches: true)
          end
          it 'page includes activate match link' do
            get opportunity_matches_path(opportunity_id: match.opportunity.id)
            expect(response.body).to include('Activate Match')
          end
        end
      end

      describe 'can see alternate clients AND you are the in the initial contact types for this route on this match (and the match is active)' do
        before do
          match.update(active: true)
          match.dnd_staff_contacts << contact
          role.update(can_edit_assigned_programs: true, can_see_alternate_matches: true)
          user.roles << role
        end
        it 'can access the page' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.status).to eq 200
        end

        it 'page does not include activate match link' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.body).to_not include('Activate Matches')
        end

        describe 'when client has can_activate_matches' do
          before do
            role.update(can_activate_matches: true)
          end
          it 'page includes activate match link' do
            get opportunity_matches_path(opportunity_id: match.opportunity.id)
            expect(response.body).to include('Activate Match')
          end
        end
      end

      describe 'if you are a default contact on the sub-program of the type that receives initial contact' do
        before do
          match.sub_program.dnd_staff_contacts << contact
          role.update(can_edit_assigned_programs: true, can_see_alternate_matches: true)
          user.roles << role
        end
        it 'can access the page' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.status).to eq 200
        end

        it 'page does not include activate match link' do
          get opportunity_matches_path(opportunity_id: match.opportunity.id)
          expect(response.body).to_not include('Activate Matches')
        end

        describe 'when client has can_activate_matches' do
          before do
            role.update(can_activate_matches: true)
          end
          it 'page includes activate match link' do
            get opportunity_matches_path(opportunity_id: match.opportunity.id)
            expect(response.body).to include('Activate Match')
          end
        end
      end
    end
  end
end
