class SetStallDates < ActiveRecord::Migration[4.2]
  def up
    # Set the stall_date on any match that is currently on the three stall-able steps
    match_ids = Set.new
    match_ids += MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin.pending.joins(:match).merge(ClientOpportunityMatch.active.open).pluck(:match_id)
    match_ids += MatchDecisions::ApproveMatchHousingSubsidyAdmin.pending.joins(:match).merge(ClientOpportunityMatch.active.open).pluck(:match_id)
    match_ids += MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator.pending.joins(:match).merge(ClientOpportunityMatch.active.open).pluck(:match_id)
    MatchProgressUpdates::Base.where(submitted_at: nil).where(match_id: match_ids.to_a).group(:match_id).maximum(:requested_at).each do |match_id, requested_at|
      stall_date = (requested_at&.to_date || Date.current) + 30.days
      ClientOpportunityMatch.find(match_id).update(stall_date: stall_date)
    end
  end
end
