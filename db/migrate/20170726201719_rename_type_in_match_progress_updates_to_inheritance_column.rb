class RenameTypeInMatchProgressUpdatesToInheritanceColumn < ActiveRecord::Migration
  def change
    rename_column :match_progress_updates, :type, :inheritance_column
  end
end
