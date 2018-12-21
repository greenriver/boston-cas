class CreateNeighborhoodInterest < ActiveRecord::Migration
  def change
    create_table :neighborhood_interests do |t|
      t.references :client
      t.references :neighborhood

      t.timestamps
    end
  end
end
