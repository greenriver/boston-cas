###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHsaReviewDecline < ::Notifications::Base
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

    def decision
      match.thirteen_hsa_review_decline_decision
    end

    def event_label
      "#{Translation.translate('CoC Thirteen')} notified of #{Translation.translate('HSA Thirteen')} decline.  Confirmation pending."
    end
  end
end
