###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Six
  class ApproveMatchHousingSubsidyAdmin < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.six_approve_match_housing_subsidy_admin_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} notified of approved potential match."
    end
  end
end
