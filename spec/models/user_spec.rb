###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { create :user }

  describe 'validations' do
    context 'if email missing' do
      let(:user) { build :user, email: nil }

      it 'is invalid' do
        expect( user ).to be_invalid
      end
    end
  end

  describe 'client access permissions' do
    let(:rule) { create :age_greater_than_sixty }
    let(:positive) { create :requirement, rule: rule, positive: true }
    let(:limited_client_viewer_role) { create :limited_client_viewer }
    let(:admin_role) { create :admin_role }
    let(:user_only_see_age_greater_than_60) { create :user_two, requirements: [positive], roles: [limited_client_viewer_role] }
    let(:admin_user) { create :user_three, roles: [admin_role] }
    let(:shelter_role) { create :shelter_role }
    let(:limited_user) { create :user_four, roles: [shelter_role] }
    let!(:young_client) { create :client, date_of_birth: 20.years.ago }
    let!(:old_client) { create :client, date_of_birth: 70.years.ago }

    it 'limited user has no viewable clients' do
      expect(Client.visible_by(limited_user).count).to eq(0)
    end

    it 'user with some access to have one viewable client' do
      aggregate_failures 'checking counts' do
        expect(Client.visible_by(user_only_see_age_greater_than_60).count).to eq(1)
        expect(Client.visible_by(user_only_see_age_greater_than_60).pluck(:id)).to eq([old_client.id])
      end
    end

    it 'admin user to have two viewable clients' do
      aggregate_failures 'checking counts' do
        expect(Client.visible_by(admin_user).count).to eq(2)
        expect(Client.visible_by(admin_user).pluck(:id).sort).to eq([young_client.id, old_client.id].sort)
      end
    end
  end

  describe 'CVE-2026-32700 - confirmation token/unconfirmed_email sync' do
    it 'prevents desync when a concurrent request modifies unconfirmed_email mid-flight' do
      attacker_email = 'attacker@example.com'
      victim_email   = 'victim@example.com'

      user = create(:user)
      # First email change — clears dirty tracking; in-memory clean value is now attacker_email
      user.update!(email: attacker_email)

      # Simulate a concurrent request that stomps unconfirmed_email in the DB
      # while the attacker's AR instance is still in memory
      User.where(id: user.id).update_all(
        unconfirmed_email: victim_email,
        confirmation_token: 'injected_token',
      )

      # Second update with the same email — without the patch, AR considers
      # unconfirmed_email unchanged (still 'attacker_email' in memory) and
      # omits it from the UPDATE, leaving 'victim_email' in the DB
      user.update!(email: attacker_email)

      user.reload
      # The patch ensures unconfirmed_email is always written, correcting the DB
      expect(user.unconfirmed_email).to eq(attacker_email)
      expect(user.confirmation_token).not_to eq('injected_token')
    end
  end
end
