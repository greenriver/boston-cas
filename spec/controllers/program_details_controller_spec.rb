###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramDetailsController, type: :controller do
  describe 'PATCH #update requirements' do
    let(:sub_program) { create(:sub_program, program: create(:program, name: 'Old Name')) }
    let(:requirement_owner) { sub_program.program }
    let(:changed_attributes) { { name: 'New Name' } }
    let(:minimal_role_attributes) { { can_view_programs: true, can_edit_programs: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: {
          program_id: requirement_owner.id,
          sub_program_id: sub_program.id,
          program: { name: 'New Name', requirements_attributes: requirements },
        }
      end
    end

    it_behaves_like 'assignable requirements'
  end
end
