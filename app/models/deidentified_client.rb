class DeidentifiedClient < ActiveRecord::Base
  validates :client_identifier, uniqueness: true
  has_one :project_client, ->  do
    where(
      data_source_id: DataSource.where(db_identifier: 'Deidentified').select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false
  has_one :client, through: :project_client, required: false
  has_many :client_opportunity_matches, through: :client
  
  has_paper_trail
  acts_as_paranoid
  
  def involved_in_match?
    client_opportunity_matches.exists?
  end
  
  def cohort_names
    Warehouse::Cohort.active.where(id: self.active_cohort_ids).pluck(:name).join("\n")
  end
  
  def populate_project_client project_client
    project_client.first_name = first_name
    project_client.last_name = last_name
    project_client.active_cohort_ids = active_cohort_ids

    project_client.sync_with_cas = true
    project_client.needs_update = true
    project_client.save
  end

  def log message
    Rails.logger.info message
  end

  def update_project_clients_from_deidentified_clients
    data_source_id = DataSource.where(db_identifier: 'Deidentified').pluck(:id).first
    
    # remove unused ProjectClients
    ProjectClient.where(
      data_source_id: data_source_id).
      where.not(id_in_data_source: DeidentifiedClient.select(:id)).
      delete_all
      
    # update or add for all DeidentifiedClients
    DeidentifiedClient.all.each do |deidentified_client|
      project_client = ProjectClient.where(
        data_source_id: data_source_id, 
        id_in_data_source: deidentified_client.id
      ).first_or_initialize
      deidentified_client.populate_project_client(project_client)
    end

    log "Updated #{DeidentifiedClient.count} ProjectClients from DeidentifiedClients"
  end
  
end
