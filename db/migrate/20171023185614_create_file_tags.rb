class CreateFileTags < ActiveRecord::Migration[4.2]
  def change
    create_table :file_tags do |t|
      t.references :sub_program, null: false
      t.string :name
      t.integer :tag_id
    end
  end
end
