###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImmediateMailer, type: :mailer do
  let(:message) { create(:message) }

  describe '.immediate' do
    it 'sends when the recipient has an active user' do
      contact = create(:contact, email: 'active@example.com')
      create(:user, contact: contact)

      expect do
        described_class.immediate(message, contact.email).deliver_now
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'does not send when the recipient has an inactive user' do
      contact = create(:contact, email: 'inactive@example.com')
      create(:user, contact: contact, active: false)

      expect do
        described_class.immediate(message, contact.email).deliver_now
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end

    it 'does not send when the recipient contact has no user' do
      contact = create(:contact, email: 'no-user@example.com')

      expect do
        described_class.immediate(message, contact.email).deliver_now
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end

    it 'does not send when there is no contact for the recipient email' do
      expect do
        described_class.immediate(message, 'unknown@example.com').deliver_now
      end.not_to(change { ActionMailer::Base.deliveries.size })
    end
  end
end
