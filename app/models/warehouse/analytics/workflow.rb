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
        preload(:match_route, :initialized_decisions, :initial_decision, opportunity: :voucher).
        merge(ProjectClient.from_hmis).
        find_in_batches(batch_size: 500) do |matches|
        batch = []
        matches.each do |match|
          completed_at = nil
          terminal_status = nil
          unsuccessful_reason = nil
          if match.closed?
            completed_at = match.initialized_decisions.to_a.map(&:updated_at).max
            terminal_status = match.overall_status[:name]
            unsuccessful_reason = match.unsuccessful_reason&.name
          end
          batch << new(
            id: match.id,
            client_id: match.client_id,
            opportunity_id: match.opportunity_id,
            opportunity_category_id: match.opportunity.voucher.sub_program_id,
            workflow_name: match.match_route.title,
            started_at: match.initial_decision&.updated_at,
            completed_at: completed_at,
            stalled: match.decision_stalled?, # NOTE: this causes an N+1 query
            current_status: match.overall_status[:name], # NOTE: this causes an N+1 query
            terminal_status: terminal_status,
            unsuccessful_reason: unsuccessful_reason,
            created_at: match.created_at,
            updated_at: match.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
