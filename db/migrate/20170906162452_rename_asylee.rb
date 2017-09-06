class RenameAsylee < ActiveRecord::Migration
  def change
    rename_column :clients, :assylee, :asylee
    rename_column :project_clients, :assylee, :asylee
  end
end
