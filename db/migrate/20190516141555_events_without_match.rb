class EventsWithoutMatch < ActiveRecord::Migration[4.2]
  def up
    add_column :match_events, :client_id, :integer

    # link up existing events to the sourcing client
    MatchEvents::Base.find_each do |event|

      unless event.match.nil?
        event.update(client_id: event.match.client_id)
      end
    end
  end

  def down
    remove_column :match_events, :client_id
  end

end