###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eight
  class EightAssignManager < Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.eight_assign_manager_decision
    end

    def event_label
      Translation.translate("#{Translation.translate('Housing Subsidy Administrator Eight')} notified, match awaiting case manager assignment")
    end
  end
end
