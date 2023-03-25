###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class Vouchers
    require 'csv'
    require 'json'

    def run!
      # fetch the MVP list of Vouchers
      csv = CSV.read('db/vouchers.csv', headers: true, encoding: 'bom|utf-8')
      Rails.logger.info "Importing roughly #{csv.length} sub-programs with vouchers"
      count = 0
      voucher_count = 0
      Rails.logger.info "Funding Sources in CSV may not match exactly, make sure you update them prior to import"
      ApplicationRecord.transaction do
        csv.each do |row|
          unless row["Program Name"].nil?

            f = FundingSource.find_by(name: row["Funding Source"])
            #puts f.inspect
            s = Subgrantee.where(name: row["Service Provider"]).first_or_create do |s|
              s.name = row["Service Provider"]
            end
            sc = Subgrantee.where(name: row["Sub-Contractor"]).first_or_create do |sc|
              sc.name = row["Sub-Contractor"]
            end
            hsa = Subgrantee.where(name: row["Housing Subsidy Administrator"]).first_or_create do |hsa|
              hsa.name = row["Housing Subsidy Administrator"]
            end

            services = []
            unless row["Services"].nil?
              services = Service.where(name: row["Services"].split(/\s*,\s*/))
              # puts services.inspect
            end

            p = Program.where(name: row["Program Name"]).first_or_create do |p|
              p.name = row["Program Name"]
              p.funding_source = f
            end
            p.services = services
            # puts p.inspect
            # SubPrograms that are Project-Based need a building.  We don't yet have a
            # mechanism to set that from the spreadsheet, so we picked a default
            building = nil
            vouchers = []
            units = []
            if row["Project, Tenant, or Sponsor based?"] == 'Project-Based'
              building = Building.where(name: row["Site if project-based"]).first_or_create do |building|
                building.name = row["Site if project-based"]
                building.subgrantee = s
              end
              row["# of Units available if project-based"].to_i.times do |i|
                vouchers << Voucher.new
                voucher_count += 1
                units << Unit.create(name: i + 1, available: true, building: building)
              end
            else
              row["# of Vouchers if not project-based"].to_i.times do
                vouchers << Voucher.new
                voucher_count += 1
              end
            end

            sp = SubProgram.create(name: row["Subprograms"], program: p, program_type: row["Project, Tenant, or Sponsor based?"], building: building, vouchers: vouchers, service_provider: s, sub_contractor: sc, housing_subsidy_administrator: hsa)
            count += 1

          end
        end
      end
      Rails.logger.info "Added #{count} sub-programs with #{voucher_count} vouchers"

    end

  end
end
