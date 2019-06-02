###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisionReasons
  class Base < ActiveRecord::Base
    # Pick-list reasons associated with a particular match decision
    # Reasons are currently split up by actor type
    # + special other option and shelter agency
    # no longer working with the client
    # Per requirements in https://www.pivotaltracker.com/story/show/118185729
    # Feel free to change how available reasons are associated with decisions
    # as the requirements evolve
    # ~@rrosen, 5/24/2016

    self.table_name = 'match_decision_reasons'

    scope :active, -> { where(active: true) }

    validates :name, presence: true

    def other?
      false
    end

    def not_working_with_client?
      false
    end

  end
end