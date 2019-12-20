class AddAlternateNamesToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :alternate_names, :string
    add_column :project_clients, :alternate_names, :string
  end
end
