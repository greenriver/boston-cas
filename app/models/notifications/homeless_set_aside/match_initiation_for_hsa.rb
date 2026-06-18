###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::HomelessSetAside
  class MatchInitiationForHsa < ::Notifications::Base
    def self.contact_types_for_notification
      [:housing_subsidy_admin_contacts]
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator')} notified of match detail"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end

    def contacts_editable?
      true
    end
  end
end
