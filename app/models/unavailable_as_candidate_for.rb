###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# This is used to determine whether or not a client is available to match a
# specific match route, existence of a record in this table for a given route
# means the client is unavailable.
class UnavailableAsCandidateFor < ApplicationRecord
  belongs_to :client
  belongs_to :route, class_name: 'MatchRoutes::Base', primary_key: :type, foreign_key: :match_route_type
  belongs_to :user, optional: true
  belongs_to :match, class_name: 'ClientOpportunityMatch', optional: true
  has_paper_trail

  ACTIVE_MATCH_TEXT = 'Active Match'.freeze
  SUCCESSFUL_MATCH_TEXT = 'Successful Match'.freeze
  PARKED_TEXT = 'Parked'.freeze

  scope :for_route, ->(route) do
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
      where(arel_table[:expires_at].lt(Date.current)).
      destroy_all
  end

  def self.download_columns
    {
      'First Name' => ->(parked) { parked.client.first_name },
      'Last Name' => ->(parked) { parked.client.last_name },
      'CAS Client ID' => ->(parked) { parked.client_id },
      'Remote ID' => ->(parked) { parked.client.remote_id },
      'Remote Source' => ->(parked) do
        parked.client.remote_data_source&.name if parked.client.remote_data_source # rubocop:disable Style/SafeNavigation
      end,
      'Route' => ->(parked) { parked.route.title },
      'Parked On' => ->(parked) { parked.created_at.to_date },
      'Parked Until' => ->(parked) { parked.expires_at&.to_date || 'Indefinite' },
      'Parked By' => ->(parked) { parked.user&.name_with_email },
      'Parked Reason' => ->(parked) { parked.reason },
    }
  end
end
