class AddLimitClientNamesOnMatchesToConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :configs, :limit_client_names_on_matches, :boolean, default: true
  end
end
