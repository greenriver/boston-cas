###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Seven
  class ApproveMatchHousingSubsidyAdminFromDnd < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.seven_approve_match_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator')} notified of approved potential match."
    end
  end
end
