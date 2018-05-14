module Warehouse
  class BuildReport
    def run!
      Warehouse::CasReport.transaction do
        # Replace all CAS data in the warehouse every time
        Warehouse::CasReport.delete_all
        at = MatchDecisions::Base.arel_table
        ::Client.joins( :project_client, client_opportunity_matches: :decisions ).preload(
          :project_client,
          {
            client_opportunity_matches: [
              :dnd_staff_contacts,
              :housing_subsidy_admin_contacts,
              :client_contacts,
              :shelter_agency_contacts,
              :ssp_contacts,
              :hsp_contacts,
              decisions: [
                :decline_reason,
                :not_working_with_client_reason,
                :administrative_cancel_reason,
              ],
              opportunity: [voucher: :sub_program],
            ]
          }
        ).where( at[:status].not_eq nil ).distinct.find_each do |client|
          client_id = client.project_client.id_in_data_source
          client.client_opportunity_matches.each do |match|
            # similar to match.current_decision, but more efficient given that we've preloaded all the decisions
            decisions = match.decisions.select(&:status).sort_by(&:id)
            # Debugging 
            # puts decisions.map{|m| [m[:id], m[:type], m.status, m.label, m.label.blank?]}.uniq.inspect
            sub_program = match.sub_program
            current_decision = decisions.last
            match_route = match.match_route
            previous_updated_at = nil
            match_started_decision = match.send(match_route.initial_decision)
            match_started_at = if match_started_decision.started?
              match_started_decision.updated_at
            else
              nil
            end
            decisions.each_with_index do |decision, idx|
              if previous_updated_at
                elapsed_days = ( decision.updated_at.to_date - previous_updated_at.to_date ).to_i
              end
              # we want to be able to report on wether or not the HSA requested a CORI check
              # so we'll split that step into two
              step_name = decision.step_name
              if decision.type == 'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin'
                if decision.status == 'no_hearing'
                  step_name += ' - no hearing requested'
                elsif decision.status == 'scheduled'
                  step_name += ' - hearing requested'
                end
              end
              
              Warehouse::CasReport.create!(
                client_id: client_id,
                match_id: match.id,
                decision_id: decision.id,
                decision_order: match_route.class.match_steps_for_reporting[decision.type],
                match_step: step_name,
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
                cori_release_form_submitted: decision.cori_release_form_submitted,
                match_started_at: match_started_at,
                program_type: sub_program.program_type,
                shelter_agency_contacts: contact_details(match.shelter_agency_contacts),
                hsa_contacts: contact_details(match.housing_subsidy_admin_contacts),
                ssp_contacts: contact_details(match.ssp_contacts),
                admin_contacts: contact_details(match.dnd_staff_contacts),
                clent_contacts: contact_details(match.client_contacts),
                hsp_contacts: contact_details(match.hsp_contacts)
              )
              previous_updated_at = decision.updated_at
            end
          end
        end
      end
    end

    def contact_details contacts
      contacts.map do |contact| 
        {
          name: contact.name, 
          email: contact.email,
        }
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
