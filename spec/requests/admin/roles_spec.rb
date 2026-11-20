###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
    let!(:role) { create(:role, name: 'Changed', can_view_reports: false, can_view_buildings: true) }
    let!(:untouched_role) { create(:role, name: 'Untouched', can_view_reports: false, can_view_buildings: true) }

    it 'updates only the posted permissions and leaves unposted permissions and other roles unchanged' do
      role.update!(can_view_full_ssn: true)

      patch batch_update_admin_roles_path,
            params: { role: { role.id.to_s => { can_view_reports: '1', can_view_buildings: '0' } } }

      expect(response).to redirect_to(admin_roles_path)
      expect(flash[:notice]).to eq('Roles updated successfully.')
      expect(role.reload.slice(:can_view_reports, :can_view_buildings, :can_view_full_ssn)).to eq(
        'can_view_reports' => true, 'can_view_buildings' => false, 'can_view_full_ssn' => true,
      )
      expect(untouched_role.reload.slice(:can_view_reports, :can_view_buildings)).to eq('can_view_reports' => false, 'can_view_buildings' => true)
    end

    it 'rolls back every posted role and shows an alert when a posted role does not exist' do
      missing_id = Role.maximum(:id) + 1

      patch batch_update_admin_roles_path, params: {
        role: {
          role.id.to_s => { can_view_reports: '1' },
          missing_id.to_s => { can_view_reports: '1' },
          untouched_role.id.to_s => { can_view_reports: '1' },
        },
      }

      expect(response).to redirect_to(admin_roles_path)
      expect(flash[:alert]).to start_with('Update failed: ')
      expect(role.reload.can_view_reports).to be(false)
      expect(untouched_role.reload.can_view_reports).to be(false)
    end

    it 'redirects without changing any role when no role is posted' do
      patch batch_update_admin_roles_path

      expect(response).to redirect_to(admin_roles_path)
      expect(role.reload.slice(:can_view_reports, :can_view_buildings)).to eq('can_view_reports' => false, 'can_view_buildings' => true)
    end

    it 'ignores unpermitted attributes like name' do
      original_name = role.name
      patch batch_update_admin_roles_path,
            params: { role: { role.id.to_s => { can_view_reports: '1', name: 'hacked' } } }

      expect(response).to redirect_to(admin_roles_path)
      expect(role.reload.name).to eq(original_name)
      expect(role.can_view_reports).to be(true)
    end

    it 'redirects to root with an alert and changes nothing when the user cannot edit roles' do
      limited_user = create(:user)
      limited_user.roles << create(:role)
      sign_in limited_user

      patch batch_update_admin_roles_path, params: { role: { role.id.to_s => { can_view_reports: '1' } } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Sorry you are not authorized to do that.')
      expect(role.reload.can_view_reports).to be(false)
    end
  end
end
