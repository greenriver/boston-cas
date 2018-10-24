class AddFamilyMemberToDeidentifiedClients < ActiveRecord::Migration
  def change
    add_column :deidentified_clients, :family_member, :boolean, null: false, default: false
  end
end
