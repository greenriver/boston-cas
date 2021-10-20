###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class Base < ApplicationRecord
    # Pick-list reasons associated with a particular match decision
    # Reasons are currently split up by actor type
    # + special other option and shelter agency
    # no longer working with the client
    # Per requirements in https://www.pivotaltracker.com/story/show/118185729
    # Feel free to change how available reasons are associated with decisions
    # as the requirements evolve
    # ~@rrosen, 5/24/2016

    self.table_name = 'match_decision_reasons'

    has_many :decisions, class_name: 'MatchDecisions::Base', foreign_key: :decline_reason_id

    scope :active, -> { where(active: true, limited: false) }
    scope :limited, -> { where(active: true, limited: true) }

    scope :ineligible_in_warehouse, -> do
      where(ineligible_in_warehouse: true)
    end

    validates :name, presence: true

    def other?
      false
    end

    def not_working_with_client?
      false
    end
  end
end
