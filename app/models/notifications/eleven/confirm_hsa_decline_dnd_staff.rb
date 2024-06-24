###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eleven
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
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
