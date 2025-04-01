###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Workflow < ::Warehouse::Base
  self.table_name = 'cas_analytics_workflows'
  def self.sync!
    transaction do
      delete_all
      # All matches for HMIS (warehouse) clients
      ::ClientOpportunityMatch.joins(client: :project_client, opportunity: :voucher).
        preload(:match_route, opportunity: :voucher).
        merge(ProjectClient.from_hmis).
        find_in_batches(batch_size: 500) do |matches|
        batch = []
        matches.each do |match|
          batch << new(
            id: match.id,
            client_id: match.client_id,
            opportunity_id: match.opportunity_id,
            opportunity_category_id: match.opportunity.voucher.sub_program_id,
            workflow_name: match.match_route.title,
            # started_at: match.created_at,
            # completed_at: match.updated_at,
            created_at: match.created_at,
            updated_at: match.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
