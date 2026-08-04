###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class CreateMatchDecisionSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :match_decision_steps do |t|
      t.references :route, null: false
      t.string :decision_type, null: false
      t.integer :default_referral_result

      t.timestamps
    end

    add_index :match_decision_steps, [:route_id, :decision_type], unique: true, name: 'index_decision_steps_on_route_and_decision_type'
  end
end
