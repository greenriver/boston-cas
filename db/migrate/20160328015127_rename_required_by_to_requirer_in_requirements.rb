class RenameRequiredByToRequirerInRequirements < ActiveRecord::Migration
  def change
    rename_column :requirements, :required_by_id, :requirer
    rename_column :requirements, :required_by_type, :requirer_type
  end
end
