class RePopulateNonHmisClientAssessments < ActiveRecord::Migration[6.0]
  def up
    with_assessment_ids = NonHmisAssessment.pluck(:non_hmis_client_id)
    NonHmisClient.where.not(id: with_assessment_ids).with_deleted.each do |client|
      client.build_assessment_if_missing
    end
  end
end
