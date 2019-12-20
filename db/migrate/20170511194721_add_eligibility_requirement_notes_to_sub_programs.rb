class AddEligibilityRequirementNotesToSubPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_programs, :eligibility_requirement_notes, :text
  end
end
