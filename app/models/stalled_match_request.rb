###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class StalledMatchRequest < ::ApplicationRecord
  belongs_to :match,
      class_name: ClientOpportunityMatch.name,
      inverse_of: :stalled_match_requests

    has_many :notifications,
      class_name: Notifications::Base.name

    belongs_to :decision,
      class_name: MatchDecisions::Base.name,
      inverse_of: :stalled_match_requests

    has_one :match_route, through: :match
    delegate :stalled_interval, to: :match_route

end