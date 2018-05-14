class AddClientIdentifierToClientAndProjectClient < ActiveRecord::Migration
  def change
    add_column :project_clients, :client_identifier, :string
    add_column :clients, :client_identifier, :string
  end
end
