class MoveHomelessNights < ActiveRecord::Migration[6.0]
  def change
    IdentifiedPathwaysVersionThree.where.not(additional_homeless_nights: nil).find_each do |assessment|
      assessment.update(additional_homeless_nights_sheltered: assessment.additional_homeless_nights, additional_homeless_nights: 0)
    end
    DeidentifiedPathwaysVersionThree.where.not(additional_homeless_nights: nil).find_each do |assessment|
      assessment.update(additional_homeless_nights_sheltered: assessment.additional_homeless_nights, additional_homeless_nights: 0)
    end
    IdentifiedPathwaysVersionThree.where.not(days_homeless_in_the_last_three_years: nil).find_each do |assessment|
      assessment.update(homeless_nights_sheltered: assessment.days_homeless_in_the_last_three_years, days_homeless_in_the_last_three_years: 0)
    end
    DeidentifiedPathwaysVersionThree.where.not(days_homeless_in_the_last_three_years: nil).find_each do |assessment|
      assessment.update(homeless_nights_sheltered: assessment.days_homeless_in_the_last_three_years, days_homeless_in_the_last_three_years: 0)
    end
  end
end
