class EventsWithoutMatch < ActiveRecord::Migration
  def up
    add_column :match_events, :client_id, :integer

    # link up existing events to the sourcing client
    MatchEvents::Base.all.each do |event|

      unless event.match.nil?
        event.client = event.match.client
        event.save!
      end
    end
  end

  def down
    remove_column :match_events, :client_id
  end

end
