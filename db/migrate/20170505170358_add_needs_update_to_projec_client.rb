class AddNeedsUpdateToProjecClient < ActiveRecord::Migration
  def change
    add_column :project_clients, :needs_update, :boolean, default: false, null: false
  end
end
