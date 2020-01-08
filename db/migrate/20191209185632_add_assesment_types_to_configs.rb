class AddAssesmentTypesToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :deidentified_client_assessment, :string, default: 'DeidentifiedClientAssessment'
    add_column :configs, :identified_client_assessment, :string, default: 'IdentifiedClientAssessment'
  end
end
