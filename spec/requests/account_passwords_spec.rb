###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade.
#
# The signed-in "change my password" flow (AccountPasswordsController#update via
# `update_with_password`) exercises Devise :recoverable/:validatable/:password_archivable.
# These specs characterize current 7.2 behavior so a regression surfaces in CI.
RSpec.describe 'AccountPasswords', type: :request do
  let(:password) { Digest::SHA256.hexdigest('abcd1234abcd') }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:new_password) { 'N3w-Str0ng-Passphrase-2026' }

  before { sign_in user }

  describe 'PATCH /account_password' do
    it 'changes the password when the current password is correct' do
      patch account_password_path,
            params: {
              user: {
                current_password: password,
                password: new_password,
                password_confirmation: new_password,
              },
            }

      expect(response).to redirect_to(edit_account_password_path)
      expect(user.reload.valid_password?(new_password)).to be true
    end

    it 'does not change the password when the current password is wrong' do
      patch account_password_path,
            params: {
              user: {
                current_password: 'not-the-current-password',
                password: new_password,
                password_confirmation: new_password,
              },
            }

      user.reload
      expect(user.valid_password?(new_password)).to be false
      expect(user.valid_password?(password)).to be true
    end
  end
end
