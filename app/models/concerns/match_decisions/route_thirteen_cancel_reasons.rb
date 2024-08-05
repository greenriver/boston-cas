###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteThirteenCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [].tap do |reasons|
        reasons << 'Incarcerated'
        reasons << 'Institutionalized'
        reasons << 'In Treatment/Recovery Center'
        reasons << 'Match expired' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
          'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess',
        ].include?(type)
        reasons << 'Client has declined match' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        ].include?(type)
        reasons << 'Client has disengaged' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        ].include?(type)
        reasons << 'Client has disappeared' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        ].include?(type)
        reasons << 'CORI' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        ].include?(type)
        reasons << 'SORI' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
        ].include?(type)
        reasons << 'Vacancy should not have been entered'
        reasons << 'Client received another housing opportunity'
        reasons << 'Client no longer eligible for match' unless [
          'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess',
        ].include?(type)
        reasons << 'Client deceased'
        reasons << 'Vacancy filled by other client' unless [
          'MatchDecisions::Thirteen::ThirteenClientMatch',
          'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement',
          'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess',
        ].include?(type)
        reasons << 'Health and Safety' unless [
          'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess',
        ].include?(type)
        reasons << 'Do not allow other matches for this vacancy' unless [
          'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess',
        ].include?(type)
        reasons << 'Other'
      end
    end
  end
end
