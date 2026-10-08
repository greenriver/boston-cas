###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenConfirmMatchSuccessFyi < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :hsp_contacts, :ssp_contacts]
    end

    def decision
      match.fourteen_confirm_match_success_decision
    end

    def event_label
      'Match contacts notified that match success confirmation is underway.'
    end
  end
end
