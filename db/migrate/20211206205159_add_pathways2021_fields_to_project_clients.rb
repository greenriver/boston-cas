class AddPathways2021FieldsToProjectClients < ActiveRecord::Migration[6.0]
  def change
    [
       :project_clients,
       :clients,
    ].each do |table|
      add_column table, :address, :string
    end
  end
end
