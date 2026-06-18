###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Client < ::Warehouse::Base
  self.table_name = 'cas_analytics_clients'

  # Process any client who came from the warehouse (HMIS) and has had a match
  # at some point in history
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      ::Client.joins(:client_opportunity_matches, :project_client).
        preload(:project_client).
        merge(ProjectClient.from_hmis).distinct.find_in_batches(batch_size: 1_000) do |clients|
        batch = []
        clients.each do |client|
          hmis_client_id = client.project_client.id_in_data_source
          next unless hmis_client_id.present?

          batch << new(
            id: client.id,
            client_id: hmis_client_id,
            calculated_first_homeless_night: client.calculated_first_homeless_night,
            calculated_last_homeless_night: client.calculated_last_homeless_night,
            created_at: client.created_at,
            updated_at: client.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
