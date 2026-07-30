###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class MatchDecisionStep < ApplicationRecord
  belongs_to :route, class_name: 'MatchRoutes::Base'

  validates :decision_type, presence: true, uniqueness: { scope: :route_id }

  def supports_declines?
    decision_class = decision_type.safe_constantize
    decision_class.present? && decision_class.include?(MatchDecisions::AcceptsDeclineReason)
  end

  # Matches how the match page labels the "Current Step" (@match.current_decision.step_name).
  def display_name
    decision_type.safe_constantize&.new&.step_name || decision_type.demodulize.titleize
  end
end
