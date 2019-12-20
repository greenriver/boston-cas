class RenameShouldRunEngineToShouldActivateMatch < ActiveRecord::Migration[4.2]
  def change
    rename_column :match_routes, :should_run_engine, :should_activate_match
  end
end
