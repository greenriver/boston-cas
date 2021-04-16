class CopyAgencyIdIntoAssessments < ActiveRecord::Migration[6.0]
  def change
    NonHmisAssessment.find_each do |assessment|
      assessment.update!(agency_id: assessment.non_hmis_client.agency_id)
    end
  end
end
