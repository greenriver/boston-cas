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
          clients = Client.all.pluck(:id)
          if clients.size == 0
            to_add = ProjectClient.where(calculated_chronic_homelessness: 1).pluck(:id)
            to_add += ProjectClient.where(sync_with_cas: true).pluck(:id)
          else
            project_clients = ProjectClient.where(calculated_chronic_homelessness: 1).pluck(:client_id)
            project_clients += ProjectClient.where(sync_with_cas: true).pluck(:client_id)
            missing_clients = ProjectClient.where(client_id: project_clients - clients).pluck(:id)
            no_clients = ProjectClient.where(calculated_chronic_homelessness: 1).where(client_id: nil).pluck(:id)
            no_clients += ProjectClient.where(sync_with_cas: true).where(client_id: nil).pluck(:id)
            probably_clients = ProjectClient.where(sync_with_cas: 1).where.not(client_id: nil).order(client_id: :asc).pluck(:client_id)

            to_add = (no_clients.uniq + missing_clients.uniq).uniq
            to_delete = (clients - project_clients.uniq).uniq
            to_update = (probably_clients + (project_clients.uniq & clients)).uniq
          end
          if to_delete.any?
            Rails.logger.info "Removing #{to_delete.length} clients"
            to_delete.uniq.each do |d|
              Client.where(id: d).each do |c|
                c.destroy
              end
            end
          end
          Rails.logger.info "Adding #{to_add.length} clients"
          to_add.each do |a|
            pc_attr = fetch_project_client(:id, a)
            c = Client.create(pc_attr)
            # make note of our new connection in project_clients
            pc = ProjectClient.find(a)
            pc.update_attributes(client_id: c.id)
          end
          if to_update.any?
            Rails.logger.info "Updating #{to_update.length} clients"
            to_update.each do |u|
              pc_attr = fetch_project_client(:client_id, u)
              pc_attr.delete(:id)
              c = Client.find_by(id: u)
              # ignore available flag if this client has previously been merged
              if c[:merged_into].present?
                pc_attr.delete(:available)
              end
              vispdat_length_homeless_in_days = pc_attr[:vispdat_length_homeless_in_days]
              vispdat_score = pc_attr[:vispdat_score]
              pc_attr = pc_attr.merge(vispdat_priority_score: calculate_vispdat_priority_score(vispdat_length_homeless_in_days, vispdat_score))
              pc_attr.delete(:vispdat_length_homeless_in_days)
              c.update_attributes(pc_attr)
            end
          end

          ProjectClient.update_all(needs_update: false)
        end
        fix_incorrect_available_candidate_clients()
        # Data has changed, see if we have any new matches
        Matching::RunEngineJob.perform_later
      else
        fix_incorrect_available_candidate_clients()
      end
    end

    # Find anyone who should be marked as available_candidate, but for whatever reason isn't marked as such
    def fix_incorrect_available_candidate_clients
      clients = Client.where(available_candidate: false, available: true, prevent_matching_until: nil)
      clients.each do |c|
        if c.client_opportunity_matches.active.none? && c.client_opportunity_matches.success.none?
          if c.client_opportunity_matches.count < Client.max_candidate_matches
            c.update(available_candidate: true)
          end
        end
      end
    end

    private

    def calculate_vispdat_priority_score vispdat_length_homeless_in_days, vispdat_score
      vispdat_length_homeless_in_days ||= 0
      vispdat_score ||= 0
      if vispdat_length_homeless_in_days > 730 && vispdat_score >= 8
        730 + vispdat_score
      elsif vispdat_length_homeless_in_days >= 365 && vispdat_score >= 8
        365 + vispdat_score
      elsif vispdat_score >= 0 
        vispdat_score
      else 
        0
      end
    end

    def needs_update?
      ProjectClient.where(needs_update: true).any?
    end

    def fetch_project_client by, id
      pc = ProjectClient.where(by => id).select(
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
        :sober_housing
      ).first
      pc_attr = pc.attributes.map do |k,v|
        [k.to_sym, v]
      end.to_h
      pc_attr[:available] = pc.available?
      if pc_attr[:veteran_status] == '1'
        pc_attr[:veteran] = 1
      end
      if pc_attr[:developmental_disability] != 1
        pc_attr[:developmental_disability] = nil
      end
      pc_attr[:substance_abuse_problem] = pc.substance_abuse?

      # convert ProjectClient into Client format
      {
        chronic_homeless: :calculated_chronic_homelessness,
        ssn_quality: :ssn_quality_code,
        date_of_birth_quality: :dob_quality_code,
        hiv_aids: :hivaids_status,
        chronic_health_problem: :chronic_health_condition,
        race_id: :primary_race,
        ethnicity_id: :ethnicity,
        veteran_status_id: :veteran_status,
        gender_id: :gender,
      }.each do |destination, source|
        pc_attr[destination] = pc_attr[source]
        pc_attr.delete(source)
      end
      pc_attr.delete(:id)

      return pc_attr
    end
  end
end
