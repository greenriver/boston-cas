###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::OpportunityCategory < ::Warehouse::Base
  self.table_name = 'cas_analytics_clients'

  # Process any sub-program that has ever had an opportunity
  def self.sync!
    transaction do
      delete_all
      ::SubProgram.joins(:program, :sub_contractor, vouchers: :opportunity).
        preload(
          :program,
          :service_provider,
          :housing_subsidy_administrator,
          :sub_contractor,
          vouchers: :opportunity,
        ).
        merge(ProjectClient.from_hmis).distinct.find_in_batches(batch_size: 1_000) do |sub_programs|
        batch = []
        sub_programs.each do |sub_program|
          names = [
            sub_program.program.name,
            sub_program.name,
          ].uniq
          batch << new(
            full_name: names.join(' - '),
            name: sub_program.program.name,
            sub_project_name: sub_program.name,
            program_type: program_type_label,
            subgrantee_id: sub_program.service_provider&.id,
            subgrantee_name: sub_program.service_provider&.name,
            sub_contractor_id: sub_program.sub_contractor&.id,
            sub_contractor_name: sub_program.sub_contractor&.name,
            hsa_id: sub_program.housing_subsidy_administrator&.id,
            hsa_name: sub_program.housing_subsidy_administrator&.name,
          )
        end
        import!(batch)
      end
    end
  end
end
