###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eleven
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    def self.contact_types_for_notification
      [:dnd_staff_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "eleven_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.eleven_confirm_hsa_accepts_client_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Eleven')} notified of #{Translation.translate('Housing Subsidy Administrator Eleven')} decline.  Confirmation pending."
    end
  end
end
