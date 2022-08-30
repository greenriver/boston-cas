class AddPregnantLessThan28Weeks < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :pregnant_under_28_weeks, :boolean, default: false
    add_column :clients, :pregnant_under_28_weeks, :boolean, default: false
    add_column :non_hmis_clients, :pregnant_under_28_weeks, :boolean, default: false
  end
end
