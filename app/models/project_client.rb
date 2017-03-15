class ProjectClient < ActiveRecord::Base

  has_one :client, required: false
  has_one :unit, foreign_key: :id_in_data_source, primary_key: :last_homeless_night_roomid
  has_one :building, foreign_key: :id_in_data_source, primary_key: :last_homeless_night_programid

  belongs_to :data_source, required: false

  # Availability is now determined solely based on the manually set sync_with_cas 
  # column.  This generally maps to the chronically homeless list
  def available?
    sync_with_cas
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

  private

end
