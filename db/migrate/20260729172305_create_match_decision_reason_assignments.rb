###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class CreateMatchDecisionReasonAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :match_decision_reason_assignments do |t|
      t.references :route, null: false
      t.string :decision_type, null: false, default: ''
      t.references :match_decision_reason, null: false
      t.string :kind, null: false
      t.integer :position, null: false, default: 0
      t.boolean :requires_explanation, null: false, default: false
      t.integer :referral_result

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :match_decision_reason_assignments,
              [:route_id, :decision_type, :match_decision_reason_id, :kind],
              unique: true,
              name: 'index_reason_assignments_on_route_step_reason_kind'
  end
end
