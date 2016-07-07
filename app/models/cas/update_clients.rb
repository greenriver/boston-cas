module Cas
  class UpdateClients

    def run!
      to_add = []
      to_delete = []
      to_update = []

      # add clients for:
      # 1. Any project client with an empty client_id
      # 2. Any project client with a client_id that doesn't have a corresponding client
      clients = Client.all.pluck(:id)
      if clients.size == 0
        to_add = ProjectClient.where(calculated_chronic_homelessness: 1).pluck(:id)
      else
        project_clients = ProjectClient.where(calculated_chronic_homelessness: 1).pluck(:client_id)
        missing_clients = ProjectClient.where(client_id: project_clients - clients).pluck(:id)
        no_clients = ProjectClient.where(calculated_chronic_homelessness: 1).where(client_id: nil).pluck(:id)
        probably_clients = ProjectClient.where(calculated_chronic_homelessness: 1).where.not(client_id: nil).order(client_id: :asc).pluck(:client_id)

        to_add = no_clients + missing_clients
        to_delete = clients - project_clients
        to_update = probably_clients - (project_clients - clients)
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
          pc_attr.delete('id')
          c = Client.find_by(id: u)
          # ignore available flag if this client has previously been merged
          if c[:merged_into].present?
            pc_attr.delete('available')
          end

          c.update_attributes(pc_attr)
        end
      end
      # Data has changed, see if we have any new matches
      Matching::RunEngineJob.perform_later
    end

    private
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
        :project_exit_destination,
        :project_exit_destination_generic,
        :primary_race,
        :ethnicity,
        :gender,
        :income_total_monthly_last_collected,
        :income_total_monthly,
        :substance_abuse_problem
      ).first
      pc_attr = pc.attributes
      pc_attr["available"] = pc.available?
      if pc_attr["veteran_status"] == '1'
        pc_attr["veteran"] = 1
      end
      pc_attr["substance_abuse_problem"] = pc.substance_abuse?

      # convert ProjectClient into Client format
      {
        "chronic_homeless": "calculated_chronic_homelessness",
        "ssn_quality": "ssn_quality_code",
        "date_of_birth_quality": "dob_quality_code",
        "hiv_aids": "hivaids_status",
        "chronic_health_problem": "chronic_health_condition",
        "race_id": "primary_race",
        "ethnicity_id": "ethnicity",
        "veteran_status_id": "veteran_status",
        "gender_id": "gender",
        "income_information_date": "income_total_monthly_last_collected"
      }.each do |destination, source|
        pc_attr[destination] = pc_attr[source]
        pc_attr.delete(source)
      end
      pc_attr.delete("calculated_last_homeless_night")
      pc_attr.delete("project_exit_destination")
      pc_attr.delete("project_exit_destination_generic")
      pc_attr.delete('id')

      return pc_attr
    end
  end
end
