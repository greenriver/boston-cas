class CreateReissueRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :reissue_requests do |t|
      t.references :notification, index: true, foreign_key: true
      t.integer :reissued_by, index: true

      t.datetime :reissued_at
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_foreign_key :reissue_requests, :users, column: :reissued_by
  end
end
