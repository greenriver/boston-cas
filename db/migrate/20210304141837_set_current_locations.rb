class SetCurrentLocations < ActiveRecord::Migration[6.0]
  def up
    NonHmisAssessment.where.not(shelter_name: nil).joins(:user, :non_hmis_client).find_each do |assessment|
      next unless assessment.shelter_name.present?

      ShelterHistory.create(
        non_hmis_client_id: assessment.non_hmis_client_id,
        user_id: assessment.user_id,
        shelter_name: assessment.shelter_name,
        created_at: assessment.updated_at,
      )
    end
  end
  def down
    ShelterHistory.delete_all
  end
end
