class RenameShouldRunEngineToShouldActivateMatch < ActiveRecord::Migration
  def change
    rename_column :match_routes, :should_run_engine, :should_activate_match
  end
end
