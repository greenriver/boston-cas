###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramsController, type: :controller do
  describe 'POST #create requirements' do
    let(:requirement_owner) { Program.find_by!(name: 'New Program') }
    let(:changed_attributes) { { name: 'New Program' } }
    let(:minimal_role_attributes) { { can_edit_programs: true } }
    let(:send_request) do
      ->(requirements) do
        post :create, params: {
          program: {
            name: 'New Program',
            match_route_id: MatchRoutes::Default.first.id,
            sub_programs_attributes: [{ program_type: 'Sponsor-Based' }],
            requirements_attributes: requirements,
          },
        }
      end
    end

    # A create has no existing requirement to destroy
    it_behaves_like 'assignable requirements', creates_record: true
  end
end
