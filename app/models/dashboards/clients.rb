###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Dashboards::Clients
  include ArelHelper

  def initialize(start_date:, end_date:, match_route_name:)
    @start_date = start_date
    @end_date = end_date
    @match_route_name = match_route_name
  end

  def matched_clients(by:)
    @matched_clients ||= {}
    @matched_clients[by] ||= client_scope.
      distinct.
      group_by { |client| client.public_send(by).text }
  end

  def successful_clients(by:)
    @successful_clients ||= {}
    @successful_clients[by] ||= client_scope.
      merge(Reporting::Decisions.success).
      distinct.
      group_by { |client| client.public_send(by).text }
  end

  def average_days_to_success(by:)
    averages = {}
    successful_clients(by: by).each do |bucket, clients|
      total = clients.sum do |client|
        decision = client.reporting_decisions.find_by(current_step: true)
        (decision.updated_at.to_date - decision.match_started_at.to_date).to_i
      end
      averages[bucket] = (total / Float(clients.count)).round(1)
    end
    averages
  end

  def average_matches_to_success(by:)
    number_of_matches = Reporting::Decisions.
      where(
        cas_client_id: client_scope.
          merge(Reporting::Decisions.success).
          distinct.
          select(:id),
        current_step: true).
      group(:cas_client_id).
      count

    client_demographics = Client.
      where(id: number_of_matches.keys).
      group_by { |client| client.public_send(by).text }

    averages = {}
    client_demographics.each do |bucket, clients|
      sum = clients.reduce(0) { |sum, client| sum += number_of_matches[client.id]}
      averages[bucket] = (sum / Float(clients.count)).round(1)
    end

    averages
  end

  def matches_for_clients(by:, bucket:)
    client_ids = successful_clients(by: by)[bucket].map { |client| client.id }
    Reporting::Decisions.
      joins(:client).
      terminated.
      where(
        cas_client_id: client_ids,
        current_step: true,
      )
  end

  def client_scope
    Client.
      joins(:reporting_decisions).
      merge(Reporting::Decisions.
        started_between(start_date: @start_date, end_date: @end_date).
        where(match_route: @match_route_name))
  end
end
