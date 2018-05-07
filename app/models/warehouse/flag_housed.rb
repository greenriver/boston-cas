module Warehouse
  class FlagHoused
    def run!
      processed = Warehouse::CasHoused.all
      housed_in_cas = ClientOpportunityMatch.should_alert_warehouse
      to_add = housed_in_cas.where.not(id: processed.pluck(:match_id))
      to_add.each do |match|
        warehouse_client_id = match.client.project_client.id_in_data_source
        cas_client_id = match.client.id
        match_id = match.id
        housed_on = match.confirm_match_success_dnd_staff_decision.updated_at

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
