###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenMatchAcknowledgementFyi < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts, :hsp_contacts, :ssp_contacts, :dnd_staff_contacts]
    end

    def decision
      match.fourteen_match_acknowledgement_decision
    end

    def event_label
      'Match contacts notified that match acknowledgement is underway.'
    end
  end
end
