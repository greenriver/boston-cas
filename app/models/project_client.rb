class ProjectClient < ActiveRecord::Base
  has_one :client, required: false, primary_key: :client_id, foreign_key: :id

  belongs_to :data_source, required: false

  scope :in_data_source, lambda { |data_source|
    joins(:data_source).merge(DataSource.where(id: data_source.id))
  }

  scope :available, lambda {
    where(sync_with_cas: true)
  }

  scope :has_client, lambda {
    where.not(client_id: nil).joins(:client)
  }

  scope :needs_client, lambda {
    where(
      arel_table[:client_id].eq(nil).or(
        arel_table[:client_id].not_in(Client.pluck(:id)),
      ),
    )
  }

  scope :update_pending, lambda {
    where(needs_update: true)
  }

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
    true
  end

  # Attempt to find matching contacts for data coming from the warehouse
  def shelter_agency_contacts
    default_shelter_agency_contacts&.map do |email|
      Contact.where(Contact.arel_table[:email].matches(email))&.first
    end&.compact || []
  end
end
