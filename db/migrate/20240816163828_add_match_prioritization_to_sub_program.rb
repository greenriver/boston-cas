class AddMatchPrioritizationToSubProgram < ActiveRecord::Migration[7.0]
  def change
    add_reference :sub_programs, :match_prioritization
  end
end
