class RemoveOldRaceGender < ActiveRecord::Migration[6.0]
  def change
    remove_column :project_clients, :primary_race, :string
    remove_column :project_clients, :secondary_race, :string
    remove_column :project_clients, :gender, :integer
    remove_column :clients, :race_id, :integer
    remove_column :clients, :gender_id, :integer
    remove_column :clients, :gender_other, :string
  end
end
