class TweakDndReviewColumnsOnMatch < ActiveRecord::Migration[4.2]
  def change
    rename_column :client_opportunity_matches, :dnd_recommendation_status, :match_recommendation_dnd_staff_status
    add_column :client_opportunity_matches, :match_recommendation_dnd_staff_contact_id, :integer
    add_column :client_opportunity_matches, :match_recommendation_dnd_staff_timestamp, :datetime
  end
end
