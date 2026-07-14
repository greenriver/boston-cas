class FixDefaultCasing < ActiveRecord::Migration[7.2]
  def change
    change_column_default :configs, :vacancy_submission_mechanism, from: 'Traditional', to: 'traditional'
  end
end
