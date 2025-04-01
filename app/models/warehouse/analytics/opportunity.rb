###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Opportunity < ::Warehouse::Base
  self.table_name = 'cas_analytics_opportunities'
  # Process all opportunities
  def self.sync!
    transaction do
      delete_all
      ::Opportunity.joins(:voucher).
        preload(voucher: :unit).
        distinct.
        find_in_batches(batch_size: 1_000) do |opportunities|
        batch = []
        opportunities.each do |opportunity|
          batch << new(
            id: opportunity.id,
            unit_id: opportunity.voucher.unit_id,
            unit_name: opportunity.voucher&.unit&.name,
            created_at: opportunity.created_at,
            updated_at: opportunity.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
