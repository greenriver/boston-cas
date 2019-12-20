class AddRandomTieBreakerToClient < ActiveRecord::Migration[4.2]
  def up
    add_column :clients, :tie_breaker, :float

    Client.add_missing_tie_breakers
  end

  def down
    remove_column :clients, :tie_breaker
  end
end
