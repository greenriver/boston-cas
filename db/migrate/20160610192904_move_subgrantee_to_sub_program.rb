class MoveSubgranteeToSubProgram < ActiveRecord::Migration
  def change
    add_column :sub_programs, :sub_contractor_id, :integer, index: true 
    add_foreign_key :sub_programs, :subgrantees, column: :sub_contractor_id
  end
end
