###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class HousingSubsidyAdministratorAccepted < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts, :dnd_staff_contacts]
    end

    def decision
      match.four_schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} and #{Translation.translate('DND')} were notified of #{Translation.translate('Housing Subsidy Administrator')} match acceptance"
    end
  end
end
