class AddMetadataToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :user_id, :integer
    add_column :versions, :contact_id, :integer
    add_column :versions, :session_id, :string
    add_column :versions, :request_id, :string
  end
end
