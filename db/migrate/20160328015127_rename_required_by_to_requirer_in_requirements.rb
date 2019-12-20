class RenameRequiredByToRequirerInRequirements < ActiveRecord::Migration[4.2]
  def change
    rename_column :requirements, :required_by_id, :requirer
    rename_column :requirements, :required_by_type, :requirer_type
  end
end
