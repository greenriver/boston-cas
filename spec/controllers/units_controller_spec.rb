###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitsController, type: :controller do
  describe 'PATCH #update requirements' do
    let(:requirement_owner) { create(:unit, name: 'Old Name', building: create(:building)) }
    let(:changed_attributes) { { name: 'New Name' } }
    let(:minimal_role_attributes) { { can_view_units: true, can_edit_units: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: { id: requirement_owner.id, unit: { name: 'New Name', requirements_attributes: requirements } }
      end
    end

    it_behaves_like 'assignable requirements'
  end
end
