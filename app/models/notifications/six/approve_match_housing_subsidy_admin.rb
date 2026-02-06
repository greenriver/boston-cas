###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Six
  class ApproveMatchHousingSubsidyAdmin < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
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
      match.six_approve_match_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator Six')} notified of approved potential match."
    end
  end
end
