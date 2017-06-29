class MarkCanceledMatchesAsCanceled < ActiveRecord::Migration
  def up
    ClientOpportunityMatch.joins(:decisions).
      where(closed: true, closed_reason: 'rejected').
      where(match_decisions: {status: 'canceled'}).
      update_all(closed_reason: 'canceled')
  end

  def down
    ClientOpportunityMatch.joins(:decisions).
      where(closed: true, closed_reason: 'canceled').
      update_all(closed_reason: 'rejected')
  end
end
