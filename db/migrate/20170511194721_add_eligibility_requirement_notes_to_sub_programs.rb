class AddEligibilityRequirementNotesToSubPrograms < ActiveRecord::Migration
  def change
    add_column :sub_programs, :eligibility_requirement_notes, :text
  end
end
