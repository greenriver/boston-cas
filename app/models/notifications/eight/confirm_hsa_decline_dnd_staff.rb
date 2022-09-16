###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class ConfirmHsaDeclineDndStaff < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eight_confirm_housing_subsidy_admin_decline_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} notified of #{_('Housing Subsidy Administrator')} decline. Confirmation pending."
    end
  end
end
