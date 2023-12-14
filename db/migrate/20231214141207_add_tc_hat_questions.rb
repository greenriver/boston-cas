class AddTcHatQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :tc_hat_single_parent_child_over_ten, :boolean, default: false
    add_column :non_hmis_assessments, :tc_hat_legal_custody, :boolean
    add_column :non_hmis_assessments, :tc_hat_will_gain_legal_custody, :boolean
  end
end
