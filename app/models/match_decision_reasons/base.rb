###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisionReasons
  class Base < ApplicationRecord
    CLIENT_REJECTED = 2
    PROVIDER_REJECTED = 3

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

    def referral_result_text
      return 'Client Rejected' if referral_result == CLIENT_REJECTED
      return 'Provider Rejected' if referral_result == PROVIDER_REJECTED

      ''
    end

    def other?
      name == 'Other'
    end
  end
end
