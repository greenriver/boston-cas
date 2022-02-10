###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# NOTE: for the time-being these are only valid for non-HMIS clients who have been attached to
# a warehouse client
# Currently these are all the same:
# 1. 4.19.7 PrioritizationStatus - everyone in CAS is on the list (1)
# 2. 4.19.4 AssessmentLevel - all assessments are housing needs assessments (2)
# 3. 4.19.3 AssessmentType - are all virtual (2)
module Warehouse
  class CeAssessment < Base
    self.table_name = :cas_ce_assessments

    def self.involved_assessments
      NonHmisAssessment.joins(non_hmis_client: :client).
        merge(NonHmisClient.warehouse_attached)
    end

    def self.sync!
      warehouse_assessment_ids = pluck(:cas_non_hmis_assessment_id)
      assessment_ids = involved_assessments.distinct.pluck(:id)

      to_remove = warehouse_assessment_ids - assessment_ids
      where(id: to_remove).destroy_all if to_remove.any?

      to_add = []
      added = Set.new
      involved_assessments.find_each do |assessment|
        next if added.include?(assessment.id)

        to_add << {
          cas_client_id: assessment.non_hmis_client.client.id,
          cas_non_hmis_assessment_id: assessment.id,
          hmis_client_id: assessment.non_hmis_client.warehouse_client_id,
          assessment_date: assessment.entry_date,
          assessment_location: assessment.hud_assessment_location.presence || 'CAS',
          assessment_type: assessment.hud_assessment_type.presence || 2,
          assessment_level: assessment.hud_assessment_level,
          assessment_status: 1, # Placed on prioritization list
          assessment_created_at: assessment.created_at,
          assessment_updated_at: assessment.updated_at,
        }
        added << assessment.id
      end

      import(
        to_add,
        on_duplicate_key_update: {
          conflict_target: :cas_non_hmis_assessment_id,
          columns: [
            :cas_client_id,
            :cas_non_hmis_assessment_id,
            :hmis_client_id,
            :assessment_date,
            :assessment_location,
            :assessment_type,
            :assessment_level,
            :assessment_status,
            :assessment_created_at,
            :assessment_updated_at,
          ],
        },
      )
    end
  end
end
