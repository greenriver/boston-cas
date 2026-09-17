###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenSubsidyAdminScreeningFyi < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts, :hsp_contacts, :ssp_contacts, :dnd_staff_contacts]
    end

    def decision
      match.fourteen_subsidy_admin_screening_decision
    end

    def event_label
      'Match contacts notified that subsidy administrator screening is underway.'
    end
  end
end
