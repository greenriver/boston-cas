###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'csv'

class PrioritizedClientsExporter
  attr_reader :active_client_ids

  # Exports client data to CSV format for prioritized matches
  #
  # @param active_matches [Array<Client>] Clients with active matches
  # @param available_matches [Array<Client>] Clients available for matching
  # @param opportunity [Opportunity] The housing opportunity being matched
  # @param current_user [User] The user requesting the export
  def initialize(active_matches:, available_matches:, opportunity:, current_user:)
    @active_matches = active_matches
    @available_matches = available_matches
    @opportunity = opportunity
    @current_user = current_user
    @active_client_ids = @active_matches.pluck(:client_id)
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      # Include a notes column in the download
      csv << headers(view_type: :download)
      @active_matches.each do |client|
        csv << row_for_client(client, active: true, view_type: :download)
      end
      @available_matches.each do |client|
        csv << row_for_client(client, active: false, view_type: :download)
      end
    end
  end

  def prioritized_column_labels
    [].tap do |result|
      @opportunity.match_route.prioritized_client_columns.map(&:to_sym).each do |column|
        column_data = prioritized_column_data[column]
        next if column_data.blank?

        if column_data[:display_check].present?
          # These checks are delegated to current_user from ApplicationController
          next unless @current_user.public_send(column_data[:display_check])
        end
        result << column_data[:title]
      end
    end
  end

  def prioritized_column_values(client)
    [].tap do |result|
      @opportunity.match_route.prioritized_client_columns.map(&:to_sym).each do |column|
        column_data = prioritized_column_data[column]
        next if column_data.blank?

        if column_data[:display_check].present?
          next unless @current_user.public_send(column_data[:display_check])
        end

        value = client.send(column)
        value = value.join('; ') if value.is_a?(Array)
        is_boolean = [true, false].include?(value)

        display_value = if is_boolean
          value ? 'Yes' : 'No'
        else
          value
        end
        result << display_value
      end
    end
  end

  def match_routes(client)
    counts = client.client_opportunity_matches.active.open.
      joins(:program, :match_route).
      where.not(opportunity: @opportunity).
      group(:type).
      count
    counts.map do |key, value|
      [key.constantize.new.title, value]
    end
  end

  private

  def headers(view_type: :view)
    headers = ['Client Name']
    headers += ['CAS ID', 'Remote ID', 'Data Source'] if view_type == :download
    headers += ['Referral Date'] if view_type == :download
    headers += prioritized_column_labels
    headers += ['Other Active Matches', 'Status'] if view_type == :view
    headers += ['Notes'] if view_type == :download
    headers
  end

  def row_for_client(client, active:, view_type: :view)
    referral_date = (client.match_for_opportunity(@opportunity)&.match_created_event&.date if active) || ''
    row = [client_name(client)]
    data_source = client.remote_data_source
    data_source_name = nil
    data_source_name = data_source.name if data_source
    row += [client.id, client.remote_id, data_source_name] if view_type == :download
    row += [referral_date] if view_type == :download
    row += prioritized_column_values(client)
    row += [other_active_matches(client), status(client)] if view_type == :view
    row += [''] if view_type == :download
    row
  end

  def client_name(client)
    match = client.match_for_opportunity(@opportunity)
    confidential_opportunity = @opportunity.confidential? && !client.has_full_housing_release?(@opportunity&.match_route)
    confidential_client = client.confidential? || match.try(:confidential?)

    # In the controller, show_confidential_names depends on params[:confidential_override]
    # For CSV export, we assume we don't have this override.
    show_confidential = @current_user.can_view_client_confidentiality?
    hide_client_name = (confidential_client || confidential_opportunity) && !show_confidential

    match&.client_name_for_contact(@current_user.contact, hidden: hide_client_name) || client.client_name_for_user(@current_user, hidden: hide_client_name)
  end

  def other_active_matches(client)
    match_routes(client).map { |route_name, matches_count| "#{route_name} (#{matches_count})" }.join('; ')
  end

  def status(client)
    @active_client_ids.include?(client.id) ? 'Current Active Match' : ''
  end

  def prioritized_column_data
    @prioritized_column_data ||= Client.prioritized_columns_data
  end
end
