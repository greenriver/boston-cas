class CopyAgencyIdIntoAssessments < ActiveRecord::Migration[6.0]
  def up
    NonHmisAssessment.find_each do |assessment|
      agency_id = assessment.non_hmis_client&.agency_id
      assessment.update_column(:agency_id, agency_id) if agency_id
    end
  end
end
