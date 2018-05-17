# This is used to determine whether or not a client is available to match a 
# specific match route, existence of a record in this table for a given route
# means the client is unavailable.
class UnavailableAsCandidateFor < ActiveRecord::Base
  belongs_to :client

  scope :for_route, -> (route) do
    where(match_route_type: route.class.name)
  end

  validates_presence_of :match_route_type

end