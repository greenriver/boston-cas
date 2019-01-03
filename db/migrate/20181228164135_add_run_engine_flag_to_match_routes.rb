class AddRunEngineFlagToMatchRoutes < ActiveRecord::Migration
  def change
    add_column :match_routes, :should_run_engine, :boolean, default: true, null: false
  end
end
