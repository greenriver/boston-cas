class AddConfidentialFlagToSubProgram < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_programs, :confidential, :boolean, default: false, null: false
  end
end
