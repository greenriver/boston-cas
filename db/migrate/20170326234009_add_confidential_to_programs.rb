class AddConfidentialToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :confidential, :boolean, default: false, null: false
  end
end
