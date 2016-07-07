class CreateVeteranStatuses < ActiveRecord::Migration
  def change
    create_table :veteran_statuses do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
