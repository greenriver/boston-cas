class AddConfidentialFlagToSubProgram < ActiveRecord::Migration
  def change
    add_column :sub_programs, :confidential, :boolean, default: false, null: false
  end
end
