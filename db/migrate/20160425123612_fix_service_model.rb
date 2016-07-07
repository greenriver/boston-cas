class FixServiceModel < ActiveRecord::Migration
  def change
    remove_column :services, :contact_id, :integer
    remove_column :services, :project_id, :integer
    remove_column :services, :opportunity_id, :integer

    add_column :services, :deleted_at, :datetime, index: true

    create_table :building_services do |t|
      t.integer :building_id, index: true
      t.integer :service_id, index: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end

    create_table :program_services do |t|
      t.integer :program_id, index: true
      t.integer :service_id, index: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end

    create_table :subgrantee_services do |t|
      t.integer :subgrantee_id, index: true
      t.integer :service_id, index: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end

    create_table :funding_source_services do |t|
      t.integer :funding_source_id, index: true
      t.integer :service_id, index: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end

    create_table :service_rules do |t|
      t.integer :rule_id, index: true
      t.integer :service_id, index: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
