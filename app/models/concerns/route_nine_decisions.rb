###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteNineDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :nine_match_recommendation, decision_class_name: 'MatchDecisions::Nine::NineMatchRecommendation', notification_class_name: 'Notifications::Nine::NineMatchRecommendation'
    has_decision :nine_record_voucher_date, decision_class_name: 'MatchDecisions::Nine::NineRecordVoucherDate', notification_class_name: 'Notifications::Nine::NineRecordVoucherDate'
    has_decision :nine_confirm_voucher_decline, decision_class_name: 'MatchDecisions::Nine::NineConfirmVoucherDecline', notification_class_name: 'Notifications::Nine::NineConfirmVoucherDecline'
    has_decision :nine_assign_case_contact, decision_class_name: 'MatchDecisions::Nine::NineAssignCaseContact', notification_class_name: 'Notifications::Nine::NineAssignCaseContact'
    has_decision :nine_lease_up, decision_class_name: 'MatchDecisions::Nine::NineLeaseUp', notification_class_name: 'Notifications::Nine::NineLeaseUp'
    has_decision :nine_confirm_lease_up_decline, decision_class_name: 'MatchDecisions::Nine::NineConfirmLeaseUpDecline', notification_class_name: 'Notifications::Nine::NineConfirmLeaseUpDecline'
    has_decision :nine_assign_manager, decision_class_name: 'MatchDecisions::Nine::NineAssignManager', notification_class_name: 'Notifications::Nine::NineAssignManager'
    has_decision :nine_confirm_assign_manager_decline, decision_class_name: 'MatchDecisions::Nine::NineConfirmAssignManagerDecline', notification_class_name: 'Notifications::Nine::NineConfirmAssignManagerDecline'
    has_decision :nine_confirm_match_success, decision_class_name: 'MatchDecisions::Nine::NineConfirmMatchSuccess', notification_class_name: 'Notifications::Nine::NineConfirmMatchSuccess'
  end
end
