class DestroyRouteElevenMatches < ActiveRecord::Migration[7.0]
  def up
    ClientOpportunityMatch.joins(:match_route).where(match_routes: { type: 'MatchRoutes::Eleven' }).destroy_all unless Rails.env.production?
  end
end
