###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Roles', type: :request do
  let!(:admin_role) { create(:admin_role) }
  let!(:admin) { create(:user) }

  before do
    admin.roles << admin_role
    sign_in admin
  end

  describe 'PATCH batch_update_admin_roles' do
    let!(:role) { create(:role, can_view_reports: false) }

    it 'updates multiple roles and redirects to admin_roles_path' do
      patch batch_update_admin_roles_path, params: { role: { role.id.to_s => { can_view_reports: '1' } } }

      expect(response).to redirect_to(admin_roles_path)
      expect(role.reload.can_view_reports).to be true
    end

    it 'ignores unpermitted attributes like name' do
      original_name = role.name
      patch batch_update_admin_roles_path,
            params: { role: { role.id.to_s => { can_view_reports: '1', name: 'hacked' } } }
      expect(role.reload.name).to eq(original_name)
    end
  end
end
