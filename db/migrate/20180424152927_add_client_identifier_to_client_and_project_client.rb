class AddClientIdentifierToClientAndProjectClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :client_identifier, :string
    add_column :clients, :client_identifier, :string
  end
end
