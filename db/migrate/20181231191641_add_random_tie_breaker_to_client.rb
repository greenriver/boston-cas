class AddRandomTieBreakerToClient < ActiveRecord::Migration
  def up
    add_column :clients, :tie_breaker, :float

    Client.find_each do |client|
      client.tie_breaker = rand
      client.save!
    end
  end

  def down
    remove_column :clients, :tie_breaker
  end
end
