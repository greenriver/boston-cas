class CreateNeighborhoods < ActiveRecord::Migration[4.2]
  def change
    create_table :neighborhoods do |t|
      t.string :name

      t.timestamps
    end
  end
end
