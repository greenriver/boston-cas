###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class NineLeaseUp < Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_lease_up_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator Nine')} notified client is awaiting #{_('Move In')}"
    end
  end
end
