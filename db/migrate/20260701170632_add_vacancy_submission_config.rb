class AddVacancySubmissionConfig < ActiveRecord::Migration[7.2]
  def change
    add_column :configs, :vacancy_submission_mechanism, :string, default: 'Traditional'
  end
end
