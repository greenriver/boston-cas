class AddActiveToMatchDecisionReasons < ActiveRecord::Migration[4.2]
  def change
    add_column :match_decision_reasons, :active, :boolean, default: true, null: false
    MatchDecisionReasons::AdministrativeCancel.
      where(name: ['7 days expired', '14 days expired']).
      update_all(active: false)
  end
end
