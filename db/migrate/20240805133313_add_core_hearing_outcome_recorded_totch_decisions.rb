class AddCoreHearingOutcomeRecordedTotchDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :match_decisions, :criminal_hearing_outcome_recorded, :boolean
  end
end
