###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade.
#
# Devise invitable routes/controllers are part of the deferred-route-loading
# risk. These specs characterize the current 7.2 behavior of the invitation
# accept flow (GET accept form + PUT accept) so a regression surfaces in CI.
RSpec.describe 'Users::Invitations', type: :request do
  let(:agency) { create(:agency) }
  let(:admin_role) { create(:admin_role) }
  let(:admin) { create(:user).tap { |u| u.roles << admin_role } }

  let!(:invited_user) do
    User.invite!(
      { email: 'invitee@example.com', first_name: 'Ann', last_name: 'Vited', agency: agency, contact: build(:contact) },
      admin,
    )
  end
  let(:raw_token) { invited_user.raw_invitation_token }

  describe 'GET /users/invitation/accept' do
    it 'renders the accept-invitation form for a valid token' do
      get accept_user_invitation_path(invitation_token: raw_token)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /users/invitation (accept)' do
    let(:new_password) { 'N3w-Str0ng-Passphrase-2026' }

    it 'accepts the invitation and sets the password' do
      put user_invitation_path,
          params: {
            user: {
              invitation_token: raw_token,
              password: new_password,
              password_confirmation: new_password,
            },
          }

      invited_user.reload
      expect(invited_user.invitation_accepted_at).to be_present
      expect(invited_user.valid_password?(new_password)).to be true
    end
  end
end
