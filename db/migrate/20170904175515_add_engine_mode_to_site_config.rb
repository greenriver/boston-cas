class AddEngineModeToSiteConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :configs, :engine_mode, :string, null: false, default: 'first-date-homeless'
  end
end
