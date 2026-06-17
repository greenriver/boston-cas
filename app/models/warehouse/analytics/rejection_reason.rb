###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::RejectionReason < ::Warehouse::Base
  self.table_name = 'cas_analytics_rejection_reasons'
  # Process all matches and decisions
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      batch = []
      ::MatchDecisionReasons::Base.active.each do |reason|
        batch << new(
          id: reason.id,
          name: reason.name,
          referral_result: reason.referral_result_text,
          created_at: reason.created_at,
          updated_at: reason.updated_at,
        )
      end
      import!(batch)
    end
  end
end
