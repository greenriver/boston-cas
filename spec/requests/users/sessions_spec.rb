###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade.
#
# Devise + Rails 8 deferred route loading is the headline risk. These request
# specs characterize the current 7.2 behavior of the custom sessions routes,
# including the `active`/`timeout` endpoints declared inside `devise_scope :user`
# (config/routes.rb), so a routing/auth regression fails in CI rather than on
# staging.
#
# NOTE: exhaustive lockout timing and password-expiry scenarios are already
# covered by spec/features/accounts_spec.rb; here we cover the request-level
# sign in/out contract plus the custom endpoints.
RSpec.describe 'Users::Sessions', type: :request do
  let(:password) { Digest::SHA256.hexdigest('abcd1234abcd') }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe 'POST /users/sign_in' do
    it 'signs in with valid credentials and reaches an authenticated page' do
      post user_session_path, params: { user: { email: user.email, password: password } }

      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include('Sign Out')
    end

    it 'rejects invalid credentials' do
      post user_session_path, params: { user: { email: user.email, password: 'wrong-password' } }

      expect(response.body).to include('Invalid Email or password')
    end
  end

  describe 'DELETE /users/sign_out' do
    it 'signs the user out' do
      sign_in user

      delete destroy_user_session_path

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /active (auto-session-timeout status)' do
    it 'reports the session as active for a signed-in user' do
      sign_in user

      get '/active'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('true')
    end
  end

  describe 'GET /timeout' do
    it 'flashes the expiry notice and redirects to root' do
      sign_in user

      get '/timeout'

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Your session expired; you have been logged out.')
    end
  end

  describe 'account lockout (:lockable, maximum_attempts = 10)' do
    it 'locks the account after the maximum number of failed sign-ins' do
      Devise.maximum_attempts.times do
        post user_session_path, params: { user: { email: user.email, password: 'wrong-password' } }
      end

      # Even the correct password is now refused because the account is locked.
      post user_session_path, params: { user: { email: user.email, password: password } }

      expect(response.body).to include('Your account is locked.')
      expect(user.reload.access_locked?).to be true
    end
  end
end
