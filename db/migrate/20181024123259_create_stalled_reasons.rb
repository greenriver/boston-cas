class CreateStalledReasons < ActiveRecord::Migration[4.2]
  def change
    create_table :stalled_responses do |t|
      t.boolean :client_engaging, default: true, null: false
      t.string :reason, null: false
      t.string :decision_type, null: false
      t.boolean :requires_note, default: false, null: false
      t.boolean :active, default: true, null: false
    end
  end
end
