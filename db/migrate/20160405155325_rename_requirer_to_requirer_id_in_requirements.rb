class RenameRequirerToRequirerIdInRequirements < ActiveRecord::Migration
  def change
    rename_column :requirements, :requirer, :requirer_id
  end
end
