###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Twelve
  class TwelveHsaConfirmMatchSuccess < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.twelve_hsa_confirm_match_success_decision
    end

    def event_label
      "#{Translation.translate('HSA Twelve')} notified of match."
    end
  end
end
