###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class RemoveDefaultFromMatchDecisionReasonAssignmentsDecisionType < ActiveRecord::Migration[8.1]
  def change
    change_column_default :match_decision_reason_assignments, :decision_type, from: '', to: nil
  end
end
