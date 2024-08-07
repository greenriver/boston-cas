class CleanupDecisionReasons < ActiveRecord::Migration[7.0]
  def up
    # This generates a hash of reasons keyed by name with ascending ids as the value
    reasons = MatchDecisionReasons::Base.all.pluck(:name, :id).group_by(&:shift).transform_values(&:flatten).transform_values(&:sort)
    reasons.each do |name, ids|
      # Nothing to do if we only have one of these
      next if ids.size == 1

      to_keep = ids.first
      to_delete = ids.drop(1)
      MatchDecisions::Base.where(decline_reason_id: to_delete).update_all(decline_reason_id: to_keep)
      MatchDecisions::Base.where(administrative_cancel_reason_id: to_delete).update_all(administrative_cancel_reason_id: to_keep)
      # Delete the duplicate records using an obvious and consistent delete date so we can find them later
      MatchDecisionReasons::Base.where(id: to_delete).update_all(deleted_at: Date.current)
      # Make sure all kept records are active
      MatchDecisionReasons::Base.where(id: to_keep).update_all(active: true)
    end
  end
end
