###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class FlagHoused
    def run!(clear=false)
      processed = Warehouse::CasHoused.all
      to_add = ClientOpportunityMatch.should_alert_warehouse
      if clear
        Warehouse::CasHoused.destroy_all
      else
        to_add = to_add.where.not(id: processed.pluck(:match_id))
      end
      to_add.each do |match|
        warehouse_client_id = match.client.project_client.id_in_data_source
        cas_client_id = match.client.id
        match_id = match.id
        housed_on = match.success_time

        cas_housed = Warehouse::CasHoused.create(
          client_id: warehouse_client_id,
          cas_client_id: cas_client_id,
          match_id: match_id,
          housed_on: housed_on
        )
      end
    end
  end
end
