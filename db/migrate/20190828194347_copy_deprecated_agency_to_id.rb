class CopyDeprecatedAgencyToId < ActiveRecord::Migration
  def up
    NonHmisClient.where.not(deprecated_agency: nil).find_each do |client|
      if client.deprecated_agency.present?
        agency = Agency.where(name: client.deprecated_agency).first_or_create
        client.update(agency_id: agency.id)
      end
    end
  end
end
