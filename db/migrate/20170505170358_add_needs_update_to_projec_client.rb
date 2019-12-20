class AddNeedsUpdateToProjecClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :needs_update, :boolean, default: false, null: false
  end
end
