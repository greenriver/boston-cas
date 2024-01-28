###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteTenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :ten_agency_confirm_match_success, decision_class_name: 'MatchDecisions::Ten::TenAgencyConfirmMatchSuccess', notification_class_name: 'Notifications::Ten::TenAgencyConfirmMatchSuccess'
    has_decision :ten_agency_confirm_match_success_decline, decision_class_name: 'MatchDecisions::Ten::TenAgencyConfirmMatchSuccessDecline', notification_class_name: 'Notifications::Ten::TenAgencyConfirmMatchSuccessDecline'
    has_decision :ten_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Ten::TenConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Ten::TenConfirmMatchSuccessDndStaff'
  end
end
