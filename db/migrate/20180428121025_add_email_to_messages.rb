class AddEmailToMessages < ActiveRecord::Migration[4.2]
  def change
    remove_column :messages, :user_id, :integer 
    add_reference :messages, :contact, null: false
  end
end
