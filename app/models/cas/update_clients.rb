###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Cas
  class UpdateClients
    def run!
      return if Client.advisory_lock_exists?('update_clients')

      Client.with_advisory_lock('update_clients') do
        if needs_update?
          # add clients for:
          # 1. Any project client with an empty client_id
          # 2. Any project client with a client_id that doesn't have a corresponding client
          ProjectClient.transaction do
            remove_unused_clients
            update_existing_clients
            add_missing_clients

            ProjectClient.update_all(needs_update: false)
          end
          # Data has changed, see if we have any new matches
          Matching::RunEngineJob.perform_later
        end
        remove_matches_with_deleted_clients
      end
    end

    def update_existing_clients
      # count = ProjectClient.has_client.update_pending.count
      # puts "Updating #{count} clients"
      ProjectClient.has_client.update_pending.preload(:client).find_in_batches do |batch|
        clients = []
        batch.each do |project_client|
          client = project_client.client
          attrs = attributes_for_client(project_client)
          # Ignore merged clients
          attrs.delete(:available) if client.merged_into.present?

          # For anyone we've forced available in CAS, also make sure they are available on all routes
          # this should be a small number of folks, so we won't bother batching it.
          force_remove_unavailable_fors = attrs.delete(:force_remove_unavailable_fors)
          client.make_available_in_all_routes if force_remove_unavailable_fors

          # Special case for holds voucher on, because sometimes these come from matches and should not
          # be overridden
          client.holds_voucher_on = project_client.holds_voucher_on unless client.holds_internal_cas_voucher
          client.assign_attributes(attrs)
          clients << client
        end
        Client.import(
          clients,
          on_duplicate_key_update: {
            conflict_target: [:id],
            columns: (Client.column_names - ['id']).map(&:to_sym),
          },
        )
      end
    end

    def add_missing_clients
      # count = ProjectClient.needs_client.count
      # puts "Adding #{count} clients"
      ProjectClient.needs_client.find_in_batches do |batch|
        clients = []
        batch.each do |project_client|
          attrs = attributes_for_client(project_client)
          attrs.delete(:force_remove_unavailable_fors)
          clients << Client.new(attrs)
        end
        result = Client.import(clients, all_or_none: true)
        raise "Failed to import #{clients.count} clients" if result.failed_instances.any?

        # make note of our new connection in project_clients
        project_clients = batch.map.with_index do |project_client, i|
          project_client.assign_attributes(client_id: result.ids[i])
          project_client
        end

        ProjectClient.import(
          project_clients,
          on_duplicate_key_update: {
            conflict_target: [:id],
            columns: [:client_id],
          },
        )
      end
    end

    def remove_unused_clients
      clients = Client.available.pluck(:id)
      project_client_client_ids = ProjectClient.available.has_client.pluck(:client_id)

      clients_to_de_activate = clients - project_client_client_ids
      # puts "Deactivating or deleting #{clients_to_de_activate.count}"
      Client.where(id: clients_to_de_activate).update_all(available: false)
      Client.where(id: clients_to_de_activate).find_each do |client|
        # remove anyone who never really participated
        # everyone else just gets marked as available false
        client.destroy if client.client_opportunity_matches.in_process_or_complete.blank?
      end
    end

    # Handle race condition
    def remove_matches_with_deleted_clients
      # Destroys any ClientOpportunityMatch that points to a deleted client.
      # This occurs when a client gets assigned to a match right after the
      # client is deleted by the `remove_unused_clients` task. This can happen
      # because the matching engine batch loads clients into memory.
      all_clients = Client.pluck(:id)
      ClientOpportunityMatch.where.not(client_id: all_clients).find_each(&:destroy)
    end

    def attributes_for_client project_client
      client_attributes = {}
      project_client_attributes.each do |attribute|
        client_attributes[attribute] = project_client.send(attribute)
      end

      # Fix up some discrepancies
      {
        available: project_client.available?,
        client_identifier: "#{project_client.data_source_id}_#{project_client.id_in_data_source}",
        substance_abuse_problem: project_client.substance_abuse?,
        veteran_status_id: project_client.veteran_status.to_i,
        veteran: project_client.veteran_status.to_i == 1,
        chronic_homeless: project_client.calculated_chronic_homelessness.to_i == 1,
        hiv_aids: project_client.hivaids_status.to_i == 1,
        chronic_health_problem: project_client.chronic_health_condition.to_i == 1,
        ssn_quality: project_client.ssn_quality_code,
        date_of_birth_quality: project_client.dob_quality_code,
        ethnicity_id: project_client.ethnicity,
      }.each do |key, value|
        client_attributes[key] = value
      end

      client_attributes[:developmental_disability] = nil unless client_attributes[:developmental_disability].to_i == 1

      # If we are set to send emails to this client, treat CAS as authoritative
      cas_client = project_client.client
      client_attributes.delete(:email) if cas_client && cas_client.email.present? && cas_client.send_emails?

      # remove non-matching column names
      [
        :vispdat_length_homeless_in_days,
        :veteran_status,
        :calculated_chronic_homelessness,
        :hivaids_status,
        :chronic_health_condition,
        :ssn_quality_code,
        :dob_quality_code,
        :primary_race,
        :ethnicity,
        :gender,
      ].each do |key|
        client_attributes.delete(key)
      end

      client_attributes
    end

    def project_client_attributes
      @project_client_attributes ||= [
        :first_name,
        :last_name,
        :ssn,
        :date_of_birth,
        :veteran_status,
        :calculated_chronic_homelessness,
        :ssn_quality_code,
        :dob_quality_code,
        :cellphone,
        :homephone,
        :workphone,
        :email,
        :hivaids_status,
        :chronic_health_condition,
        :mental_health_problem,
        :domestic_violence,
        :physical_disability,
        :disabling_condition,
        :calculated_first_homeless_night,
        :calculated_last_homeless_night,
        :ethnicity,
        :substance_abuse_problem,
        :developmental_disability,
        :sync_with_cas,
        :disability_verified_on,
        :housing_assistance_network_released_on,
        :dmh_eligible,
        :va_eligible,
        :hues_eligible,
        :hiv_positive,
        :housing_release_status,
        :vispdat_score,
        :vispdat_length_homeless_in_days,
        :vispdat_priority_score,
        :us_citizen,
        :asylee,
        :ineligible_immigrant,
        :lifetime_sex_offender,
        :meth_production_conviction,
        :family_member,
        :child_in_household,
        :days_homeless,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :days_homeless_in_last_three_years, # Pathways V4 10g (and from other sources)
        :hmis_days_homeless_last_three_years,
        :days_literally_homeless_in_last_three_years,
        :ha_eligible,
        :cspech_eligible,
        :income_total_monthly,
        :alternate_names,
        :congregate_housing,
        :sober_housing,
        :enrolled_project_ids,
        :active_cohort_ids,
        :assessment_score,
        :ssvf_eligible,
        :rrh_desired,
        :youth_rrh_desired,
        :dv_rrh_desired,
        :rrh_assessment_contact_info,
        :rrh_assessment_collected_at,
        :enrolled_in_th,
        :enrolled_in_sh,
        :enrolled_in_so,
        :enrolled_in_es,
        :enrolled_in_rrh,
        :enrolled_in_psh,
        :enrolled_in_ph,
        :enrolled_in_ph_pre_move_in,
        :enrolled_in_psh_pre_move_in,
        :enrolled_in_rrh_pre_move_in,
        :requires_wheelchair_accessibility,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_elevator_access,
        :neighborhood_interests,
        :interested_in_set_asides,
        :tags,
        :case_manager_contact_info,
        :vash_eligible,
        :pregnancy_status,
        :pregnant_under_28_weeks,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :rrh_th_desired,
        :sro_ok,
        :evicted,
        :health_prioritized,
        :is_currently_youth,
        :older_than_65,
        :assessment_name,
        :entry_date,
        :financial_assistance_end_date,
        :address,
        :tie_breaker_date,
        :majority_sheltered,
        :strengths,
        :challenges,
        :foster_care,
        :open_case,
        :housing_for_formerly_homeless,
        :drug_test,
        :heavy_drug_use,
        :sober,
        :willing_case_management,
        :employed_three_months,
        :living_wage,
        :need_daily_assistance,
        :full_time_employed,
        :can_work_full_time,
        :willing_to_work_full_time,
        :rrh_successful_exit,
        :th_desired,
        :site_case_management_required,
        :ongoing_case_management_required,
        :currently_fleeing,
        :dv_date,
        :assessor_first_name,
        :assessor_last_name,
        :assessor_email,
        :assessor_phone,
        :force_remove_unavailable_fors,
        :match_group,
        :encampment_decomissioned,
        :am_ind_ak_native,
        :asian,
        :black_af_american,
        :native_hi_pacific,
        :white,
        :female,
        :male,
        :no_single_gender,
        :transgender,
        :questioning,
        :file_tags,
        :service_need,
        :housing_barrier,
        :additional_homeless_nights_sheltered, # Pathways V4 10b
        :additional_homeless_nights_unsheltered, # Pathways V4 10d
        :total_homeless_nights_unsheltered, # Pathways V4 10f
        :calculated_homeless_nights_sheltered, # Pathways V4 10a
        :calculated_homeless_nights_unsheltered, # Pathways V4 10c
        :total_homeless_nights_sheltered, # Pathways V4 10e 
        :ongoing_es_enrollments,
        :ongoing_so_enrollments,
        :last_seen_projects,
      ]
    end

    def needs_update?
      ProjectClient.where(needs_update: true).any?
    end
  end
end
