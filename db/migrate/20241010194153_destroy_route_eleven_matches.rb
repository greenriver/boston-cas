class DestroyRouteElevenMatches < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production? 
      matches = ClientOpportunityMatch.where(match_route: MatchRoutes::Eleven.ids)
      ClientOpportunityMatch.destroy(matches.ids)
    end
  end
end
