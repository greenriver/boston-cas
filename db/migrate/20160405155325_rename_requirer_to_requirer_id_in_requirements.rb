class RenameRequirerToRequirerIdInRequirements < ActiveRecord::Migration[4.2]
  def change
    rename_column :requirements, :requirer, :requirer_id
  end
end
