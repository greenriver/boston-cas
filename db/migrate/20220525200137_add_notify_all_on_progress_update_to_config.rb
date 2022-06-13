class AddNotifyAllOnProgressUpdateToConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :configs, :notify_all_on_progress_update, :boolean, default: false
  end
end
