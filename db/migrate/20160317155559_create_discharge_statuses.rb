class CreateDischargeStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :discharge_statuses do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
