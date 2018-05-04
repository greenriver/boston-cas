class ProjectClient < ActiveRecord::Base

  has_one :client, required: false, primary_key: :client_id, foreign_key: :id

  belongs_to :data_source, required: false

  scope :available, -> do
    where(sync_with_cas: true)
  end

  scope :has_client, -> do
    where.not(client_id: nil)
  end

  scope :needs_client, -> do
    where(
      arel_table[:client_id].eq(nil).or(
        arel_table[:client_id].not_in(Client.pluck(:id))
      )
    )
  end

  scope :update_pending, -> do
    where(needs_update: true)
  end

  # Availability is now determined solely based on the manually set sync_with_cas 
  # column.  This generally maps to the chronically homeless list
  def available?
    self.sync_with_cas
  end

  def substance_abuse?
    case substance_abuse_problem
      when /.*refused.*/i,
      /client doesn't know/i,
      /no/i,
      /data not collected/i,
      nil
        return false
    end
    return true
  end

  def calculate_vispdat_priority_score
    vispdat_length_homeless_in_days ||= 0
    vispdat_score ||= 0
    vispdat_prioritized_days_score = if vispdat_length_homeless_in_days >= 730
      730
    elsif vispdat_length_homeless_in_days >= 365 && vispdat_score >= 8
      365
    else
      0
    end
    vispdat_score + vispdat_prioritized_days_score
  end
end
