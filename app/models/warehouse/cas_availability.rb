###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# for writing latest state of matches X decisions into HMIS database
module Warehouse
  class CasAvailability < Base
    self.table_name = 'cas_availabilities'


    def self.backfill
      self.transaction do
        ::Client.available.each do |client|
          if client.project_client.data_source_id == 1
            create!(
              client_id: client.project_client.id_in_data_source,
              available_at: client.created_at,
            )
          end
        end

        ::Client.unavailable.each do |client|
          client.versions.where(event: :update).reverse.each do |version|
            if version.reify.available == true
              create!(
                client_id: client.project_client.id_in_data_source,
                available_at: client.created_at,
                unavailable_at: version.created_at,
              )
            end
          end
        end

        # These clients don't have project clients so they won't have warehouse ids, we'll need
        # to look them up manually, so we'll add them all with a client_id of 0
        ::Client.only_deleted.order(:last_name, :first_name).each do |client|
          puts "DELETED CLIENT: #{client.last_name}, #{client.first_name} #{client.ssn} #{client.date_of_birth} created_at: #{client.created_at} deleted_at: #{client.deleted_at}"
          create!(
            client_id: 0,
            available_at: client.created_at,
            unavailable_at: client.deleted_at,
          )
        end
      end
    end
  end
end
