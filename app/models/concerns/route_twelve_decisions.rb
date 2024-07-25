###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteTwelveDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :twelve_agency_acknowledges_receipt, decision_class_name: 'MatchDecisions::Twelve::TwelveAgencyAcknowledgesReceipt', notification_class_name: 'Notifications::Twelve::TwelveAgencyAcknowledgesReceipt'
    has_decision :twelve_agency_acknowledges_receipt_decline, decision_class_name: 'MatchDecisions::Twelve::TwelveAgencyAcknowledgesReceiptDecline', notification_class_name: 'Notifications::Twelve::TwelveAgencyAcknowledgesReceiptDecline'
    has_decision :twelve_hsa_confirm_match_success, decision_class_name: 'MatchDecisions::Twelve::TwelveHsaConfirmMatchSuccess', notification_class_name: 'Notifications::Twelve::TwelveHsaConfirmMatchSuccess'
    has_decision :twelve_hsa_confirm_match_decline, decision_class_name: 'MatchDecisions::Twelve::TwelveHsaConfirmMatchDecline', notification_class_name: 'Notifications::Twelve::TwelveHsaConfirmMatchDecline'
    has_decision :twelve_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Twelve::TwelveConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Twelve::TwelveConfirmMatchSuccessDndStaff'
  end
end
