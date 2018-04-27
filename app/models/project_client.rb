class ProjectClient < ActiveRecord::Base

  has_one :client, required: false, primary_key: :client_id, foreign_key: :id

  belongs_to :data_source, required: false
  
  scope :in_data_source, -> (data_source) do 
    joins(:data_source).merge(DataSource.where(id: data_source.id))
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

  private

end
