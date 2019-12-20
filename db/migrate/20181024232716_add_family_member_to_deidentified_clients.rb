class AddFamilyMemberToDeidentifiedClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :family_member, :boolean, null: false, default: false
  end
end
