class AddClientUrlToDataSources < ActiveRecord::Migration[4.2]
  def change
    add_column :data_sources, :client_url, :string
  end
end
