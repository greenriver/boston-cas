###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Step < ::Warehouse::Base
  self.table_name = 'cas_analytics_steps'
  # Process all matches and decisions
  def self.sync!
    transaction do
      delete_all
      # Batch by client opportunity match as we need to work with all decisions for a given match
      ::ClientOpportunityMatch.in_batches(of: 500) do |matches|
        batch = []
        match_ids = matches.pluck(:id)
        MatchRoutes::Base.all_routes.each do |route|
          route_steps = route.match_steps_for_reporting
          ::MatchDecisions::Base.where(type: route_steps.keys, match_id: match_ids).
            where.not(status: nil).group_by(&:match_id).each do |match_id, decisions|
            decisions.sort_by! { |d| route_steps[d.type] }
            decisions.each do |decision|
              previous_decision = decisions[[decisions.index(decision) - 1, 0].max]
              batch << new(
                id: decision.id,
                referral_id: match_id,
                name: decision.step_name,
                order: route_steps[decision.type],
                status: decision.status,
                started_at: previous_decision.updated_at,
                completed_at: decision.updated_at,
                created_at: decision.created_at,
                updated_at: decision.updated_at,
              )
            end
          end
        end
        import!(batch)
      end
    end
  end
end
