###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions
  module RouteThirteenCancelReasons
    extend ActiveSupport::Concern

    def pre_hsa_decision?
      [
        'MatchDecisions::Thirteen::ThirteenClientMatch',
        'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        'MatchDecisions::Thirteen::ThirteenClientReview',
      ].include?(type)
    end

    def match_success_decision?
      type == 'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess'
    end

    def step_cancel_reasons
      [].tap do |reasons|
        reasons << 'Incarcerated'
        reasons << 'Institutionalized'
        reasons << 'In Treatment/Recovery Center'
        reasons << 'Match expired' if pre_hsa_decision?
        reasons << 'Client has declined match' unless pre_hsa_decision?
        reasons << 'Client has disengaged' unless pre_hsa_decision?
        reasons << 'Client has disappeared' unless pre_hsa_decision?
        reasons << 'CORI' unless pre_hsa_decision?
        reasons << 'SORI' unless pre_hsa_decision?
        reasons << 'Vacancy should not have been entered'
        reasons << 'Client received another housing opportunity'
        reasons << 'Client no longer eligible for match' unless match_success_decision?
        reasons << 'Client deceased'
        reasons << 'Vacancy filled by other client' unless pre_hsa_decision? || match_success_decision?
        reasons << 'Health and Safety' unless match_success_decision?
        reasons << 'Other'
      end
    end
  end
end
