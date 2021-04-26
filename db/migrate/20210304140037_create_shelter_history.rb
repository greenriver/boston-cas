class CreateShelterHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :shelter_histories do |t|
      t.references :non_hmis_client, null: false
      t.references :user, null: false
      t.string :shelter_name
      t.timestamps
    end
  end
end
