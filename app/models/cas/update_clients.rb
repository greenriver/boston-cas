module Cas
  class UpdateClients

    def run!
      if needs_update?
        to_add = []
        to_delete = []
        to_update = []

        # add clients for:
        # 1. Any project client with an empty client_id
        # 2. Any project client with a client_id that doesn't have a corresponding client
        ProjectClient.transaction do
          remove_unused_clients()
          update_existing_clients()
          add_missing_clients()
          
          ProjectClient.update_all(needs_update: false)
        end
        fix_incorrect_available_candidate_clients()
        # Data has changed, see if we have any new matches
        Matching::RunEngineJob.perform_later
      else
        fix_incorrect_available_candidate_clients()
      end
    end

    def update_existing_clients
      count = ProjectClient.has_client.update_pending.count
      puts "Updating #{count} clients"
      ProjectClient.has_client.update_pending.each do |project_client|
        client = project_client.client
        attrs = attributes_for_client(project_client)
        # Ignore merged clients
        attrs.delete(:available) if client.merged_into.present?
        client.update(attrs)
        # make note of our new connection in project_clients
        project_client.update(client_id: client.id)
      end
    end

    def add_missing_clients
      count = ProjectClient.needs_client.count
      puts "Adding #{count} clients"
      ProjectClient.needs_client.each do |project_client|
        c = Client.create(attributes_for_client(project_client))
        # make note of our new connection in project_clients
        project_client.update(client_id: c.id)
      end
    end

    def remove_unused_clients
      clients = Client.available.pluck(:id)
      project_client_client_ids = ProjectClient.available.has_client.pluck(:client_id)

      clients_to_de_activate = clients - project_client_client_ids
      puts "Deactivating or deleting #{clients_to_de_activate.count}"
      Client.where(id: clients_to_de_activate).update_all(available: false)
      Client.where(id: clients_to_de_activate).each do |client|
        # remove anyone who never really participated
        # everyone else just gets marked as available false
        if client.client_opportunity_matches.in_process_or_complete.blank?
          client.destroy
        end
      end
    end

    def attributes_for_client project_client
      client_attributes = {}
      project_client_attributes.each do |attribute|
        client_attributes[attribute] = project_client.send(attribute)
      end

      # Fix up some discrepancies
      {
        available: project_client.available?,
        substance_abuse_problem: project_client.substance_abuse?,
        veteran_status_id: project_client.veteran_status.to_i,
        veteran: project_client.veteran_status.to_i == 1,
        chronic_homeless: project_client.calculated_chronic_homelessness.to_i == 1,
        hiv_aids: project_client.hivaids_status.to_i == 1,
        chronic_health_problem: project_client.chronic_health_condition.to_i == 1,
        ssn_quality: project_client.ssn_quality_code,
        date_of_birth_quality: project_client.dob_quality_code,
        race_id: project_client.primary_race,
        ethnicity_id: project_client.ethnicity,
        gender_id: project_client.gender,
      }.each do |key, value|
        client_attributes[key] = value
      end

      client_attributes[:developmental_disability] = nil unless client_attributes[:developmental_disability].to_i == 1
      
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
        :hivaids_status,
        :chronic_health_condition,
        :mental_health_problem,
        :domestic_violence,
        :physical_disability,
        :disabling_condition,
        :calculated_first_homeless_night,
        :calculated_last_homeless_night,
        :primary_race,
        :ethnicity,
        :gender,
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
        :days_homeless_in_last_three_years,
        :ha_eligible,
        :cspech_eligible,
        :income_total_monthly,
        :alternate_names,
        :congregate_housing,
        :sober_housing,
        :enrolled_project_ids,
        :active_cohort_ids
      ]
    end

    # Find anyone who should be marked as available_candidate, but for whatever reason isn't marked as such
    def fix_incorrect_available_candidate_clients
      MatchRoutes::Base.all_routes.each do |route|
        clients = Client.available.not_parked.unavailable_in(route)
        clients.each do |c|
          if c.client_opportunity_matches.on_route(route).active.none? && c.client_opportunity_matches.success.none?
            if c.client_opportunity_matches.on_route(route).count < Client.max_candidate_matches
              c.make_available_in(match_route: route)
            end
          end
        end
      end
    end

    def needs_update?
      ProjectClient.where(needs_update: true).any?
    end
  end
end
