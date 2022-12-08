class RemoveOldRouteEightAndNine < ActiveRecord::Migration[6.0]
  def up
    Notifications::Base.where("type like '%::Nine::%' or type like '%::Eight::%'").delete_all
    MatchDecisions::Base.where("type like '%::Nine::%' or type like '%::Eight::%'").delete_all
    route_ids = MatchRoutes::Base.where(type: ['MatchRoutes::Eight', 'MatchRoutes::Nine']).pluck(:id)
    ClientOpportunityMatch.where(match_route_id: route_ids).each(&:really_destroy!)
  end
end
