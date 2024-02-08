###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class NineAssignManager < Notifications::Base
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_assign_manager_decision
    end

    def event_label
      Translation.translate("#{Translation.translate('Stabilization Service Provider Nine')} notified, match awaiting case manager assignment")
    end
  end
end
