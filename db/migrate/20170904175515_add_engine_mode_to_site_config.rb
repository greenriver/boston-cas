class AddEngineModeToSiteConfig < ActiveRecord::Migration
  def change
    add_column :configs, :engine_mode, :string, null: false, default: 'first-date-homeless'
  end
end
