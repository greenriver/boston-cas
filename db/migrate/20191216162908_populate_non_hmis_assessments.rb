class PopulateNonHmisAssessments < ActiveRecord::Migration[4.2]
  def up
    NonHmisClient.with_deleted.each do |client|
      assessment = client.client_assessments.build

      assessment.assessment_score = client.assessment_score
      assessment.actively_homeless = client.actively_homeless
      assessment.days_homeless_in_the_last_three_years = client.days_homeless_in_the_last_three_years
      assessment.veteran = client.veteran
      assessment.rrh_desired = client.rrh_desired
      assessment.youth_rrh_desired = client.youth_rrh_desired
      assessment.rrh_assessment_contact_info = client.rrh_assessment_contact_info
      assessment.income_maximization_assistance_requested = client.income_maximization_assistance_requested
      assessment.pending_subsidized_housing_placement = client.pending_subsidized_housing_placement
      assessment.requires_wheelchair_accessibility = client.requires_wheelchair_accessibility
      assessment.required_number_of_bedrooms = client.required_number_of_bedrooms
      assessment.required_minimum_occupancy = client.required_minimum_occupancy
      assessment.requires_elevator_access = client.requires_elevator_access
      assessment.family_member = client.family_member
      assessment.calculated_chronic_homelessness = client.calculated_chronic_homelessness
      assessment.neighborhood_interests = client.neighborhood_interests
      assessment.income_total_monthly = client.income_total_monthly
      assessment.disabling_condition = client.disabling_condition
      assessment.physical_disability = client.physical_disability
      assessment.developmental_disability = client.developmental_disability
      assessment.date_days_homeless_verified = client.date_days_homeless_verified
      assessment.who_verified_days_homeless = client.who_verified_days_homeless
      assessment.domestic_violence = client.domestic_violence
      assessment.interested_in_set_asides = client.interested_in_set_asides
      assessment.set_asides_housing_status = client.set_asides_housing_status
      assessment.set_asides_resident = client.set_asides_resident
      assessment.shelter_name = client.shelter_name
      assessment.entry_date = client.entry_date
      assessment.case_manager_contact_info = client.case_manager_contact_info
      assessment.phone_number = client.phone_number
      assessment.have_tenant_voucher = client.have_tenant_voucher
      assessment.children_info = client.children_info
      assessment.studio_ok = client.studio_ok
      assessment.one_br_ok = client.one_br_ok
      assessment.sro_ok = client.sro_ok
      assessment.fifty_five_plus = client.fifty_five_plus
      assessment.sixty_two_plus = client.sixty_two_plus
      assessment.voucher_agency = client.voucher_agency
      assessment.interested_in_disabled_housing = client.interested_in_disabled_housing
      assessment.chronic_health_condition = client.chronic_health_condition
      assessment.mental_health_problem = client.mental_health_problem
      assessment.substance_abuse_problem = client.substance_abuse_problem
      assessment.vispdat_score = client.vispdat_score
      assessment.vispdat_priority_score = client.vispdat_priority_score
      assessment.imported_timestamp = client.imported_timestamp

      assessment.created_at = client.created_at
      assessment.updated_at = client.updated_at
      assessment.deleted_at = client.deleted_at

      client.save
    end
  end
  def down
    # Not implemented
  end
end