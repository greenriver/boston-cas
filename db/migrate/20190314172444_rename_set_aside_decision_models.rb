class RenameSetAsideDecisionModels < ActiveRecord::Migration[4.2]
  def up
    {
      'MatchDecisions::HomelessSetAside::HsaAcknowledgesReceipt' => 'MatchDecisions::HomelessSetAside::SetAsidesHsaAcknowledgesReceipt',
      'MatchDecisions::HomelessSetAside::HsaAcceptsClient' => 'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient',
          'MatchDecisions::HomelessSetAside::RecordClientHousedDateOrDeclineHousingSubsidyAdministrator' => 'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator',
      'MatchDecisions::HomelessSetAside::ConfirmHsaAcceptsClientDeclineDndStaff' => 'MatchDecisions::HomelessSetAside::SetAsidesConfirmHsaAcceptsClientDeclineDndStaff'
    }.each do |old, new_name|
      MatchDecisions::Base.where(type: old).update_all(type: new_name)
    end

  end
end
