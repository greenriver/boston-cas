class ChangeForeignKeyConstraintForHsAs < ActiveRecord::Migration
  def up
    remove_foreign_key :sub_programs, :contacts
    remove_column :sub_programs, :contact_id
    add_column :sub_programs, :hsa_id, :integer
    add_foreign_key :sub_programs, :subgrantees, column: :hsa_id
  end

  def down
    remove_foreign_key :sub_programs, :contacts
    remove_column :sub_programs, :hsa_id
    add_column :sub_programs, :contact_id, :integer
    add_foreign_key :sub_programs, :contacts, column: :contact_id
  end
end
