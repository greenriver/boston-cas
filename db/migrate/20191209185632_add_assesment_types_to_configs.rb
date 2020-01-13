class AddAssesmentTypesToConfigs < ActiveRecord::Migration[4.2]
  def change
    add_column :configs, :deidentified_client_assessment, :string, default: 'DeidentifiedClientAssessment'
    add_column :configs, :identified_client_assessment, :string, default: 'IdentifiedClientAssessment'
  end
end
