###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::OpportunityCategory < ::Warehouse::Base
  self.table_name = 'cas_analytics_opportunity_categories'

  # Process any sub-program that has ever had an opportunity
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      ::SubProgram.joins(:program, vouchers: :opportunity).
        preload(
          :program,
          :service_provider,
          :housing_subsidy_administrator,
          :sub_contractor,
          vouchers: :opportunity,
        ).distinct.find_in_batches(batch_size: 1_000) do |sub_programs|
        batch = []
        sub_programs.each do |sub_program|
          names = [
            sub_program.program.name,
            sub_program.name,
          ].uniq
          batch << new(
            id: sub_program.id,
            full_name: names.join(' - '),
            name: sub_program.program.name,
            sub_project_name: sub_program.name,
            program_type: sub_program.program_type_label,
            subgrantee_id: sub_program.service_provider&.id,
            subgrantee_name: sub_program.service_provider&.name,
            sub_contractor_id: sub_program.sub_contractor&.id,
            sub_contractor_name: sub_program.sub_contractor&.name,
            hsa_id: sub_program.housing_subsidy_administrator&.id,
            hsa_name: sub_program.housing_subsidy_administrator&.name,
            reporting_project_id: sub_program.reporting_project_id,
            created_at: sub_program.created_at,
            updated_at: sub_program.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
