###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module CasSeeds
  class ChronicallyHomeless
    require 'csv'
    require 'json'

    def run!
      csv = CSV.read('db/project_clients.csv', headers: true, encoding: 'bom|utf-8')
      Rails.logger.info "Importing #{csv.length} Chronically Homeless Clients"
      csv.each do |row|
        # Rails.logger.info row
        # c = ProjectClient.where(id_in_data_source: row['CLID'], data_source_id_column_name: 'clid', data_source_id: 1).first_or_create
         
        # Importing from a csv that doesn't have CLID since we're bringing in data from multiple
        # sources via one CSV.  
        # TODO: when we have this hooked up to actual data sources we'll need to go back 
        # and connect folks to the appropriate source data
        c = ProjectClient.where(id_in_data_source: row['CLID'], data_source_id_column_name: 'none', data_source_id: 0).first_or_create
        c.assign_attributes row.to_hash.except('CLID')
        c.save!
      end
      Rails.logger.info 'Added Chronically Homeless Clients'
    end
  end
end