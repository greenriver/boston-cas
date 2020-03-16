class AddActorTypeToCasReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_decisions, :actor_type, :string
  end
end
