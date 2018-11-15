# This is used to determine whether or not a client is available to match a 
# specific match route, existence of a record in this table for a given route
# means the client is unavailable.
class UnavailableAsCandidateFor < ActiveRecord::Base
  belongs_to :client

  scope :for_route, -> (route) do
    route_name = MatchRoutes::Base.route_name_from_route(route)
    where(match_route_type: route_name)
  end

  validates_presence_of :match_route_type

end