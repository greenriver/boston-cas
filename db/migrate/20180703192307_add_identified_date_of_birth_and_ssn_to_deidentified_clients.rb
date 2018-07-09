class AddIdentifiedDateOfBirthAndSsnToDeidentifiedClients < ActiveRecord::Migration
  def change
    add_column :deidentified_clients, :identified, :boolean
    add_column :deidentified_clients, :date_of_birth, :date
    add_column :deidentified_clients, :ssn, :string
  end
end
