###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module RouteFourCancelReasons
    extend ActiveSupport::Concern

    def step_cancel_reasons
      [
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Incarcerated',
        'Vacancy filled by other client',
        'Client has declined match',
        'Client has disengaged',
        'Client has disappeared',
        'Match expired – No agency interaction',
        'Match expired – Agency interaction',
        'Match stalled - Agency has disengaged',
        'Match expired – No Housing Case Manager interaction',
        'Match expired – No Shelter Agency interaction',
        'Shelter Agency has disengaged',
        'Housing Case Manager has disengaged',
        'Match stalled – Housing Case Manager has disengaged',
        'Other',
      ]
    end
  end
end
