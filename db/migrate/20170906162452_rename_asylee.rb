class RenameAsylee < ActiveRecord::Migration[4.2]
  def change
    rename_column :clients, :assylee, :asylee
    rename_column :project_clients, :assylee, :asylee
  end
end
