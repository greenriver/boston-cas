class RenameClientColumnsToAvoidConflicts < ActiveRecord::Migration
  def change
    rename_column :clients, :ethnicity, :ethnicity_id
    rename_column :clients, :race, :race_id
    rename_column :clients, :veteran_status, :veteran_status_id
  end
end
