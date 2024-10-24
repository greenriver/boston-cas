###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class BuildReport
    include ArelHelper

    def run!
      fill_cas_report_table!

      return nil unless Warehouse::Base.enabled?

      fill_cas_non_hmis_client_history_table!
      fill_cas_vacancy_table!
    end

    def fill_cas_vacancy_table!
      vacancies = []
      ::Voucher.all.preload(sub_program: :program).each do |voucher|
        vacancy = Warehouse::CasVacancy.new(program_id: voucher.sub_program.program.id, sub_program_id: voucher.sub_program_id)

        vacancy.program_name = voucher.program.name
        vacancy.sub_program_name = voucher.sub_program.name
        vacancy.program_type = voucher.sub_program.program_type
        vacancy.route_name = voucher.program.match_route&.title || 'unknown'

        vacancy.vacancy_created_at = voucher.created_at
        vacancy.vacancy_made_available_at = voucher.available_at
        vacancy.first_matched_at = ClientOpportunityMatch.joins(:opportunity).
          where(opportunities: { voucher_id: voucher.id }).maximum(attribute_to_sql(Opportunity, :created_at))

        vacancies << vacancy
      end
      Warehouse::CasVacancy.transaction do
        Warehouse::CasVacancy.delete_all
        Warehouse::CasVacancy.import!(vacancies)
      end
    end

    # Utility method to generate sql for an attribute name
    private def attribute_to_sql(klass, attribute_name)
      arel_table = klass.arel_table
      connection = klass.connection
      table_name = connection.quote_table_name(arel_table.name)
      column_name = connection.quote_column_name(attribute_name)
      "#{table_name}.#{column_name}"
    end

    def fill_cas_non_hmis_client_history_table!
      history = []
      # build out entries for each time a client became available
      ::DeidentifiedClient.with_deleted.each do |client|
        # availability based on creation
        available_ons = [client.created_at] +
          client.versions.where(event: :create).pluck(:created_at)

        # unavailability based on deletion
        unavailable_ons = [client.deleted_at] +
          client.versions.where(event: :destroy).pluck(:created_at)

        available_ons = available_ons.compact.uniq.sort
        unavailable_ons = unavailable_ons.compact.uniq.sort

        available_ons.each do |available_on|
          client_history = Warehouse::CasNonHmisClientHistory.new(
            cas_client_id: client.id,
            available_on: available_on,
          )
          # See if there's a subsequent date for which we are marked unavailable
          client_history.unavailable_on = unavailable_ons.detect { |d| d > available_on }
          client_history.part_of_a_family = client.family_member
          client_history.age_at_available_on = client.age_on(available_on)
          history << client_history
        end
      end
      Warehouse::CasNonHmisClientHistory.transaction do
        Warehouse::CasNonHmisClientHistory.delete_all
        Warehouse::CasNonHmisClientHistory.import!(history)
      end
    end

    def fill_cas_report_table!
      report_data = ::Client.joins(:project_client, client_opportunity_matches: :decisions).preload(
        :project_client,
        {
          client_opportunity_matches: [
            :match_route,
            :dnd_staff_contacts,
            :housing_subsidy_admin_contacts,
            :client_contacts,
            :shelter_agency_contacts,
            :ssp_contacts,
            :hsp_contacts,
            :match_recommendation_dnd_staff_decision,
            :match_recommendation_shelter_agency_decision,
            :confirm_shelter_agency_decline_dnd_staff_decision,
            :approve_match_housing_subsidy_admin_decision,
            :confirm_housing_subsidy_admin_decline_dnd_staff_decision,
            decisions: [
              :decline_reason,
              :not_working_with_client_reason,
              :administrative_cancel_reason,
              decision_action_events: { contact: :agency },
            ],
            opportunity: [voucher: :sub_program],
            sub_program: :program,
          ],
        },
      ).where(md_b_t[:status].not_eq(nil)).distinct

      match_rows = []
      report_data.find_each do |client|
        client_id = client.project_client.id_in_data_source
        next if client_id.blank?

        data_source = data_source_name(client.project_client.data_source_id)
        client.client_opportunity_matches.each do |match|
          match_rows << fill_report_match_rows(client, client_id, data_source, match)
        end
      end

      # Oddly, calling `match_rows.flatten!` turns match_rows into nil when it is an empty array
      match_rows = match_rows.flatten.compact

      # Replace reporting decisions data
      Reporting::Decisions.transaction do
        Reporting::Decisions.delete_all
        Reporting::Decisions.import!(match_rows)
      end

      return unless Warehouse::Base.enabled?

      warehouse_rows = match_rows.map do |source_row|
        row = source_row.dup
        row[:clent_contacts] = row.delete(:client_contacts) # There is a typo in the warehouse schema
        row.except!(:current_status, :step_tag) # Not in warehouse schema
      end
      # Replace all CAS data in the warehouse every time
      Warehouse::CasReport.transaction do
        Warehouse::CasReport.delete_all
        Warehouse::CasReport.import!(warehouse_rows)
      end
    end

    def fill_report_match_rows(client, ds_client_id, data_source, match)
      sub_program = match.sub_program
      return unless sub_program.present?

      match_route = match.match_route
      return unless match_route.present?

      program = sub_program.program
      previous_updated_at = nil
      match_started_decision = match.send(match_route.initial_decision)
      match_started_at = (match_started_decision.updated_at if match_started_decision&.started?)
      # similar to match.current_decision, but more efficient given that we've preloaded all the decisions
      decisions = match.decisions.select do |decision|
        decision.status.present? && match_route.class.match_steps_for_reporting[decision.type].present?
      end.sort_by(&:id)
      # Debugging
      # puts decisions.map{|m| [m[:id], m[:type], m.status, m.label, m.label.blank?]}.uniq.inspect
      current_decision = decisions.last
      rows = []
      decisions.each_with_index do |decision, _idx|
        elapsed_days = (decision.updated_at.to_date - previous_updated_at.to_date).to_i if previous_updated_at
        # we want to be able to report on whether or not the HSA requested a CORI check
        # so we'll split that step into two
        step_name = decision.step_name
        if decision.type == 'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin'
          if decision.status == 'no_hearing'
            step_name += ' - no hearing requested'
          elsif decision.status == 'scheduled'
            step_name += ' - hearing requested'
          end
        end

        # If this a canceled or declined decision, log who did it
        event_contact = if decision.status.in?(['declined', 'canceled'])
          decision.decision_action_events.detect do |da|
            da.type == 'MatchEvents::DecisionAction' && da.action == decision.status
          end&.contact
        end

        ineligible_in_warehouse = decision&.decline_reason&.ineligible_in_warehouse || false
        current_status = if match.active? && match.stalled?
          'Stalled'
        else
          match.overall_status[:name]
        end

        row = {
          source_data_source: data_source,
          client_id: ds_client_id,
          cas_client_id: client.id,
          match_id: match.id,
          vacancy_id: match.opportunity_id,
          decision_id: decision.id,
          decision_order: match_route.class.match_steps_for_reporting[decision.type],
          match_step: step_name,
          decision_status: decision.label || 'unknown',
          current_step: decision == current_decision,
          decline_reason: explain(decision, :decline_reason),
          ineligible_in_warehouse: ineligible_in_warehouse,
          event_contact: event_contact&.name_with_email,
          event_contact_agency: event_contact&.agency&.name,
          not_working_with_client_reason: explain(decision, :not_working_with_client_reason),
          administrative_cancel_reason: explain(decision, :administrative_cancel_reason),
          active_match: match.active?,
          created_at: decision.created_at,
          updated_at: decision.updated_at,
          client_move_in_date: decision.client_move_in_date,
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
          # client_contacts has a typo in the warehouse, so do this field below
          hsp_contacts: contact_details(match.hsp_contacts),
          program_name: program.name,
          sub_program_name: sub_program.name,
          terminal_status: match.overall_status[:name],
          current_status: current_status,
          match_route: match_route.title,
          housing_type: match_route.housing_type,
          actor_type: match.current_decision.try(:actor_type) || 'N/A',
          confidential: program.confidential || sub_program.confidential,
          step_tag: decision.step_tag,
          client_contacts: contact_details(match.client_contacts),
        }
        rows << row
        previous_updated_at = decision.updated_at
      end

      rows
    end

    def data_source_name data_source_id
      @non_hmis_data_source_id ||= DataSource.where(db_identifier: 'Deidentified').pluck(:id).first
      return 'Non-HMIS' if data_source_id == @non_hmis_data_source_id

      @data_source_names ||= Hash[DataSource.pluck(:id, :name)]
      @data_source_names[data_source_id] || data_source_id
    end

    def contact_details contacts
      contacts.map do |contact|
        {
          name: contact.name,
          email: contact.email,
          agency: contact.user&.agency&.name,
        }
      end
    end

    def explain(decision, reason)
      return unless (r = decision.send(reason))

      explanation = r.name
      explanation = "#{explanation}: #{decision.send "#{reason}_other_explanation"}" if r.other?
      explanation
    end
  end
end
