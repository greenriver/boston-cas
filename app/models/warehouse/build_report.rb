module Warehouse
  class BuildReport
    def run!
      # we just flush the whole damned thing every time
      Hmis::Report.delete_all
      at = MatchDecisions::Base.arel_table
      ::Client.joins( :project_client, client_opportunity_matches: :decisions ).preload(
        :project_client,
        {
          client_opportunity_matches: {
            decisions: %i[
              decline_reason
              not_working_with_client_reason
              administrative_cancel_reason
            ]
          }
        }
      ).where( at[:status].not_eq nil ).distinct.find_each do |client|
        client_id = client.project_client.id_in_data_source
        client.client_opportunity_matches.each do |match|
          # similar to match.current_decision, but more efficient given that we've preloaded all the decisions
          decisions = match.decisions.select(&:status).sort_by(&:created_at)
          next if decisions.empty?
          current_decision = decisions.last
          previous_updated_at = nil
          decisions.each_with_index do |decision, idx|
            if previous_updated_at
              elapsed_days = ( decision.updated_at.to_date - previous_updated_at.to_date ).to_i
            end
            Hmis::Report.create!(
              client_id: client_id,
              match_id: match.id,
              decision_id: decision.id,
              decision_order: idx,
              match_step: decision.step_name,
              decision_status: decision.label,
              current_step: decision == current_decision,
              decline_reason: explain( decision, :decline_reason ),
              not_working_with_client_reason: explain( decision, :not_working_with_client_reason ),
              administrative_cancel_reason: explain( decision, :administrative_cancel_reason ),
              active_match: match.active?,
              created_at: decision.created_at,
              updated_at: decision.updated_at,
              elapsed_days: elapsed_days.to_i,
              client_last_seen_date: decision.client_last_seen_date,
              criminal_hearing_date: decision.criminal_hearing_date,
              client_spoken_with_services_agency: decision.client_spoken_with_services_agency,
              cori_release_form_submitted: decision.cori_release_form_submitted
            )
            previous_updated_at = decision.updated_at
          end
        end
      end
    end

    def explain(decision, reason)
      if r = decision.send(reason)
        explanation = r.name
        if r.other?
          explanation = "#{explanation}: #{ decision.send "#{reason}_other_explanation" }"
        end
        explanation
      end
    end
  end
end
