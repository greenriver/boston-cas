class AddGenericTieBreakerDate < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :tie_breaker_date, :date
    add_column :clients, :tie_breaker_date, :date
  end
end
