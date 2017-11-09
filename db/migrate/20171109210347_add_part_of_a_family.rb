class AddPartOfAFamily < ActiveRecord::Migration
  def change
    add_column :project_clients, :part_of_a_family, :boolean, default: false
    add_column :clients, :part_of_a_family, :boolean, default: false
  end
end
