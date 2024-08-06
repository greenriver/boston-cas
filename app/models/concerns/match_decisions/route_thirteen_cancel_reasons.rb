###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteThirteenCancelReasons
    extend ActiveSupport::Concern

    def pre_hsa_decision? = [
      'MatchDecisions::Thirteen::ThirteenClientMatch',
      'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
    ].include?(type)

    def match_success_decision?
      type == 'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess'
    end

    def step_cancel_reasons
      [].tap do |reasons|
        reasons << 'Incarcerated'
        reasons << 'Institutionalized'
        reasons << 'In Treatment/Recovery Center'
        reasons << 'Match expired' unless pre_hsa_decision? || match_success_decision?
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
        reasons << 'Do not allow other matches for this vacancy' unless match_success_decision?
        reasons << 'Other'
      end
    end
  end
end
