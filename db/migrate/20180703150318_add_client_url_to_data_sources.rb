class AddClientUrlToDataSources < ActiveRecord::Migration
  def change
    add_column :data_sources, :client_url, :string
  end
end
