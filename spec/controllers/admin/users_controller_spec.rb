###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  # role_ids is not sent, so the admin-confirmation step is not triggered.
  describe 'PATCH #update requirements' do
    let(:requirement_owner) { create(:user, first_name: 'Old') }
    let(:changed_attributes) { { first_name: 'New' } }
    let(:minimal_role_attributes) { { can_edit_users: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: { id: requirement_owner.id, user: { first_name: 'New', requirements_attributes: requirements } }
      end
    end

    it_behaves_like 'assignable requirements'
  end
end
