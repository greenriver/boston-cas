class AddFieldsToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :middle_name, :string
    add_column :deidentified_clients, :calculated_chronic_homelessness, :integer
    add_column :deidentified_clients, :gender, :integer
  end
end
