###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteElevenDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :eleven_hsa_acknowledges_receipt, decision_class_name: 'MatchDecisions::Eleven::ElevenHsaAcknowledgesReceipt', notification_class_name: 'Notifications::Eleven::MatchInitiationForHsa'
    has_decision :eleven_hsa_accepts_client, decision_class_name: 'MatchDecisions::Eleven::ElevenHsaAcceptsClient', notification_class_name: 'Notifications::Eleven::HsaAcceptsClient'
    has_decision :eleven_confirm_hsa_accepts_client_decline_dnd_staff, decision_class_name: 'MatchDecisions::Eleven::ElevenConfirmHsaAcceptsClientDeclineDndStaff', notification_class_name: 'Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff'
  end
end
