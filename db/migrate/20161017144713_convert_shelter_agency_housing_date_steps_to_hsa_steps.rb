class ConvertShelterAgencyHousingDateStepsToHsaSteps < ActiveRecord::Migration
  def change
    shelter_agency_pending_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateShelterAgency', status: 'pending')
    shelter_agency_pending_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator')
    end
    shelter_agency_future_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateShelterAgency', status: nil)
    shelter_agency_future_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator')
    end
  end
end
