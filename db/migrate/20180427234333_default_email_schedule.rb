class DefaultEmailSchedule < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :email_schedule, :string
    add_column :users, :email_schedule, :string, default: :immediate, null: false
  end
end
