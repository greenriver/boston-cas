class AddDeclineReasonToEvents < ActiveRecord::Migration[4.2]
  def change
    change_table :match_events do |t|
      t.references :not_working_with_client_reason, index: true
      t.date :client_last_seen_date
    end
  end
end
