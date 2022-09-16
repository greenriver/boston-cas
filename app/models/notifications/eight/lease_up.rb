###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class LeaseUp < Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eight_lease_up_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} notified client is awaiting Lease Up"
    end
  end
end
