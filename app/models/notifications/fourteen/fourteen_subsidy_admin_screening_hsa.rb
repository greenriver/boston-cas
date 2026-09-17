###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenSubsidyAdminScreeningHsa < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.fourteen_subsidy_admin_screening_decision
    end

    def event_label
      "#{Translation.translate('HSA Fourteen')} notified to complete subsidy administrator screening."
    end
  end
end
