class AddRunEngineFlagToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :should_run_engine, :boolean, default: true, null: false
  end
end
