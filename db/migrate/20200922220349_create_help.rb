class CreateHelp < ActiveRecord::Migration[6.0]
  def change
    create_table :helps do |t|
      t.string :controller_path, null: false
      t.string :action_name, null: false
      t.string :external_url
      t.string :title, null: false
      t.text :content, null: false
      t.string :location, default: :internal, null: false

      t.timestamps null: false, index: true
    end

    add_index :helps, [:controller_path, :action_name], unique: true
  end
end
