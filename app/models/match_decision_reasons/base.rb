###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class Base < ApplicationRecord
    self.table_name = 'match_decision_reasons'
    acts_as_paranoid

    has_many :decisions, class_name: 'MatchDecisions::Base', foreign_key: :decline_reason_id

    scope :active, -> { where(active: true, limited: false) }
    scope :limited, -> { where(active: true, limited: true) }

    scope :ineligible_in_warehouse, -> do
      where(ineligible_in_warehouse: true)
    end

    validates :name, presence: true

    def title
      name
    end

    def other?
      name == 'Other'
    end
  end
end
