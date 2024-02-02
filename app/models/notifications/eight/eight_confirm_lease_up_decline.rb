###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class EightConfirmLeaseUpDecline < ::Notifications::Base
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eight_confirm_lease_up_decline_decision
    end

    def event_label
      "#{_('DND')} notified of #{_('Housing Subsidy Administrator Eight')} decline. Confirmation pending."
    end
  end
end
