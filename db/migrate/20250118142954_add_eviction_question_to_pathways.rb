class AddEvictionQuestionToPathways < ActiveRecord::Migration[7.0]
  def change
    add_column :non_hmis_assessments, :background_check_issues_disability_or_substance_use, :boolean, default: false, null: false
  end
end
