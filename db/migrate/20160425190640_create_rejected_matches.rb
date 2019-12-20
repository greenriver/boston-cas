class CreateRejectedMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :rejected_matches do |t|
      t.references :client, index: true, null: false
      t.references :opportunity, index: true, null: false
      t.timestamps
    end
  end
end
