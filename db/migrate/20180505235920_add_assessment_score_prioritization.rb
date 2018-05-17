class AddAssessmentScorePrioritization < ActiveRecord::Migration
  def change
    MatchPrioritization::Base.ensure_all
    add_column :project_clients, :assessment_score, :integer, null: false, default: 0
    add_column :clients, :assessment_score, :integer, null: false, default: 0
  end
end
