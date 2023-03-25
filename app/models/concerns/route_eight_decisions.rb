###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteEightDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :eight_match_recommendation, decision_class_name: 'MatchDecisions::Eight::EightMatchRecommendation', notification_class_name: 'Notifications::Eight::EightMatchRecommendation'
    has_decision :eight_assign_manager, decision_class_name: 'MatchDecisions::Eight::EightAssignManager', notification_class_name: 'Notifications::Eight::EightAssignManager'
    has_decision :eight_confirm_assign_manager_decline, decision_class_name: 'MatchDecisions::Eight::EightConfirmAssignManagerDecline', notification_class_name: 'Notifications::Eight::EightConfirmAssignManagerDecline'
    has_decision :eight_record_voucher_date, decision_class_name: 'MatchDecisions::Eight::EightRecordVoucherDate', notification_class_name: 'Notifications::Eight::EightRecordVoucherDate'
    has_decision :eight_confirm_voucher_decline, decision_class_name: 'MatchDecisions::Eight::EightConfirmVoucherDecline', notification_class_name: 'Notifications::Eight::EightConfirmVoucherDecline'
    has_decision :eight_lease_up, decision_class_name: 'MatchDecisions::Eight::EightLeaseUp', notification_class_name: 'Notifications::Eight::EightLeaseUp'
    has_decision :eight_confirm_lease_up_decline, decision_class_name: 'MatchDecisions::Eight::EightConfirmLeaseUpDecline', notification_class_name: 'Notifications::Eight::EightConfirmLeaseUpDecline'
    has_decision :eight_confirm_match_success, decision_class_name: 'MatchDecisions::Eight::EightConfirmMatchSuccess', notification_class_name: 'Notifications::Eight::EightConfirmMatchSuccess'
  end
end
