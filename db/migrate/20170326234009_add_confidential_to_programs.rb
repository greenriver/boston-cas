class AddConfidentialToPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :programs, :confidential, :boolean, default: false, null: false
  end
end
