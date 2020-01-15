class CreateMatchCensus < ActiveRecord::Migration
  def change
    create_table :match_census do |t|
      t.date :date, null: false, index: true
      t.references :opportunity, null: false, index: true
      t.references :match, index: true
      t.string :program_name
      t.string :sub_program_name
      t.jsonb :prioritized_client_ids, null: false, default: []
      t.integer :active_client_id
      t.jsonb :requirements, null: false, default: []
    end
  end
end
