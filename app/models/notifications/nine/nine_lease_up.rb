###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Nine
  class NineLeaseUp < Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def decision
      match.nine_lease_up_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator Nine')} notified client is awaiting #{Translation.translate('Move In')}"
    end
  end
end
