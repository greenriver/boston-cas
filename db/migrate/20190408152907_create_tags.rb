class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
