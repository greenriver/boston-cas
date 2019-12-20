class AddShouldPreventMultipleMatchesPerClientToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :should_prevent_multiple_matches_per_client, :boolean, default: true, null: false
  end
end
