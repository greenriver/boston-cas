class CreateRejectedMatches < ActiveRecord::Migration
  def change
    create_table :rejected_matches do |t|
      t.references :client, index: true, null: false
      t.references :opportunity, index: true, null: false
      t.timestamps
    end
  end
end
