###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteFiveDecisions
  extend ActiveSupport::Concern

  included do
    has_decision :five_match_recommendation, decision_class_name: 'MatchDecisions::Five::FiveMatchRecommendation', notification_class_name: 'Notifications::Five::MatchRecommendation'
    has_decision :five_client_agrees, decision_class_name: 'MatchDecisions::Five::FiveClientAgrees', notification_class_name: 'Notifications::Five::ClientAgrees'
    has_decision :five_application_submission, decision_class_name: 'MatchDecisions::Five::FiveApplicationSubmission', notification_class_name: 'Notifications::Five::ApplicationSubmission'
    has_decision :five_screening, decision_class_name: 'MatchDecisions::Five::FiveScreening', notification_class_name: 'Notifications::Five::Screening'
    has_decision :five_mitigation, decision_class_name: 'MatchDecisions::Five::FiveMitigation', notification_class_name: 'Notifications::Five::Mitigation'
    has_decision :five_lease_up, decision_class_name: 'MatchDecisions::Five::FiveLeaseUp', notification_class_name: 'Notifications::Five::LeaseUp'
  end
end
