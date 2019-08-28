class CopyDeprecatedAgencyToAgency < ActiveRecord::Migration
  def up
    User.where.not(deprecated_agency: nil).each do |user|
      if user.deprecated_agency.present?
        agency = Agency.where(name: user.deprecated_agency).first_or_create
        user.update(agency_id: agency.id)
      end
    end
  end
end
