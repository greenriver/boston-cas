###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Four
  class ConfirmRecordClientHousedDateDeclineDndStaff < ::Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff
    def decision
      match.four_confirm_record_client_housed_date_decline_dnd_staff_decision
    end
  end
end
