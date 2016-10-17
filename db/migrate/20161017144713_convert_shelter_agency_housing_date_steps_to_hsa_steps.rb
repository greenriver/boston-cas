class ConvertShelterAgencyHousingDateStepsToHsaSteps < ActiveRecord::Migration
  def up
    shelter_agency_pending_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateShelterAgency', status: 'pending')
    shelter_agency_pending_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator')
    end
    shelter_agency_future_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateShelterAgency', status: nil)
    shelter_agency_future_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator')
    end
  end

  def down
    hsa_pending_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator', status: 'pending')
    hsa_pending_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateShelterAgency')
    end
    hsa_future_decisions = MatchDecisions::Base.where(type: 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator', status: nil)
    hsa_future_decisions.each do |d|
      d.update(type: 'MatchDecisions::RecordClientHousedDateShelterAgency')
    end
  end
end
