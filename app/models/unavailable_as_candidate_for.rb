###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# This is used to determine whether or not a client is available to match a
# specific match route, existence of a record in this table for a given route
# means the client is unavailable.
class UnavailableAsCandidateFor < ApplicationRecord
  belongs_to :client
  belongs_to :route, class_name: 'MatchRoutes::Base', primary_key: :type, foreign_key: :match_route_type
  has_paper_trail

  scope :for_route, -> (route) do
    route_name = MatchRoutes::Base.route_name_from_route(route)
    where(match_route_type: route_name)
  end

  validates_presence_of :match_route_type

  def self.available_expiration_lengths
    {
      'Indefinite' => 0,
      '30 days' => 30,
      '60 days' => 60,
      '90 days' => 90,
      '180 days' => 180,
      '365 days' => 365,
    }
  end

  def self.expiration_length
    Config.get(:unavailable_for_length)
  end

  def self.describe_expiration_length
    available_expiration_lengths.invert[expiration_length]
  end

  def self.cleanup_expired!
    where.not(expires_at: nil).
    where(arel_table[:expires_at].lt(Date.current)).destroy_all
  end

end
