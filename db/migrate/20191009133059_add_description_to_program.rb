class AddDescriptionToProgram < ActiveRecord::Migration[4.2]
  def change
    add_column :programs, :description, :text
  end
end
