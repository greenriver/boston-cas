###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class AddAudienceToMatchDecisionReasonAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :match_decision_reason_assignments, :audience, :string
  end
end
