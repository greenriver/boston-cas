class AddPartOfAFamily < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :part_of_a_family, :boolean, default: false
    add_column :clients, :part_of_a_family, :boolean, default: false
  end
end
