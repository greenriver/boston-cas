###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class AddReasonTextSnapshotsToMatchDecisions < ActiveRecord::Migration[8.1]
  def up
    add_column :match_decisions, :decline_reason_text, :string
    add_column :match_decisions, :administrative_cancel_reason_text, :string

    execute <<-SQL.squish
      UPDATE match_decisions
      SET decline_reason_text = match_decision_reasons.name
      FROM match_decision_reasons
      WHERE match_decisions.decline_reason_id = match_decision_reasons.id
    SQL

    execute <<-SQL.squish
      UPDATE match_decisions
      SET administrative_cancel_reason_text = match_decision_reasons.name
      FROM match_decision_reasons
      WHERE match_decisions.administrative_cancel_reason_id = match_decision_reasons.id
    SQL
  end

  def down
    remove_column :match_decisions, :decline_reason_text
    remove_column :match_decisions, :administrative_cancel_reason_text
  end
end
