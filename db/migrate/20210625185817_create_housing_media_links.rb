class CreateHousingMediaLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :housing_media_links do |t|
      t.references :housingable, polymorphic: true, index: {name: 'index_housing_media_links_on_housingable_type_and_id'}
      t.string :label
      t.string :url

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
