###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class EightAssignManager < Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eight_assign_manager_decision
    end

    def event_label
      _("#{_('Housing Subsidy Administrator Eight')} notified, match awaiting case manager assignment")
    end
  end
end
