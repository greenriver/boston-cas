class AddTcHatField < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :ongoing_case_management_required, :boolean, default: false
    add_column :clients, :ongoing_case_management_required, :boolean, default: false
  end
end
