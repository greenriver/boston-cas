###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade.
#
# The notification-subscriber auth routes (notification_sessions,
# notification_registrations) live under the SECOND `devise_scope :user`
# block, nested inside `resources :notifications` (config/routes.rb). This is
# precisely the shape most exposed to Rails 8 deferred route loading. These
# specs confirm those routes resolve to their controllers and render, on 7.2.
RSpec.describe 'Notification subscriber auth', type: :request do
  let(:match) { create(:client_opportunity_match) }
  # Recipient contact intentionally has no associated user so the registration
  # form is allowed to render.
  let(:recipient) { create(:contact) }
  let(:notification) do
    Notifications::ProviderOnly::HsaAcceptsClient.create!(match: match, recipient: recipient)
  end

  describe 'GET /notifications/:notification_id/sessions/new' do
    it 'resolves the second devise_scope route and renders the sign-in form' do
      get new_notification_session_path(notification.code)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /notifications/:notification_id/registrations/new' do
    it 'resolves the nested registration route and renders the registration form' do
      get new_notification_registration_path(notification.code)

      expect(response).to have_http_status(:ok)
    end
  end
end
