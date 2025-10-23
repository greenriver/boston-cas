###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::ReferralTimelineEvent < ::Warehouse::Base
  self.table_name = 'cas_analytics_referral_timeline_events'
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")

      ::ClientOpportunityMatch.joins(client: :project_client, opportunity: :voucher).
        preload(
          events: [
            :notification,
            :contact,
            decision: [
              :decline_reason,
              :not_working_with_client_reason,
            ],
          ],
          status_updates: [
            :notification,
            :contact,
          ],
        ).
        merge(ProjectClient.from_hmis).
        find_in_batches(batch_size: 500) do |matches|
          batch = []
          matches.each do |match|
            # Duplicate `timeline_events` from `ClientOpportunityMatch` to prevent N+1 queries
            timeline_events =  match.events.to_a
            timeline_events += match.status_updates.select(&:complete?).to_a
            timeline_events.each do |event|
              next if event.type == 'MatchEvents::NotificationDelivery'
              next unless event.decision.present?

              event_name = event.name
              next if event_name.blank?

              batch << new(
                name: event_name,
                event_date: event.timestamp&.to_date,
                step: event.decision&.step_name,
                referral_id: match.id,
                contact_id: event.contact_id,
                created_at: event.created_at,
                updated_at: event.updated_at,
              )
            end
          end
          import!(batch)
        end
    end
  end
end
