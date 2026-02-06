###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Six
  class ConfirmMatchSuccessDndStaff < ::Notifications::Base
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
      "six_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.six_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('CoC Six')} Staff notified of successful match and asked to give final confirmation."
    end
  end
end
