class AddAlternateNamesToClients < ActiveRecord::Migration
  def change
    add_column :clients, :alternate_names, :string
    add_column :project_clients, :alternate_names, :string
  end
end
