class CreateReportDefinitions < ActiveRecord::Migration[6.0]
  def change
    create_table :report_definitions do |t|
      t.string :report_group
      t.string :url
      t.string :name, null: false
      t.string :description
      t.integer :weight, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.boolean :limitable, default: true
    end
  end
end
