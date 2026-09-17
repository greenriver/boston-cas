###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsMailer, type: :mailer do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:contact) { create :contact }

  Notifications::Fourteen.constants.sort.each do |const|
    klass = Notifications::Fourteen.const_get(const)

    it "renders #{klass} to its recipient" do
      notification = klass.create!(match: match, recipient: contact)
      notification.decision.initialize_decision!(send_notifications: false)
      mail = described_class.public_send(notification.notification_type, notification)

      expect(mail.to).to eq([contact.email])
      expect(mail.body.encoded).to include("Hello #{contact.full_name}")
    end
  end
end
