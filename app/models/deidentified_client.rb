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

  scope :visible_to, -> (user) do
    if user.can_edit_all_clients?
      all
    else
      where(
        arel_table[:agency].eq(nil).
        or(arel_table[:agency].eq(user.agency))
      )
    end
  end

  scope :identified, -> do
    where(identified: true)
  end

  scope :deidentified, -> do
    where(identified: false)
  end

  def involved_in_match?
    client_opportunity_matches.exists?
  end

  def cohort_names
    return '' unless Warehouse::Base.enabled?
    Warehouse::Cohort.active.where(id: self.active_cohort_ids).pluck(:name).join("\n")
  end

  def populate_project_client project_client
    project_client.first_name = first_name
    project_client.last_name = last_name
    project_client.active_cohort_ids = active_cohort_ids
    project_client.assessment_score = assessment_score || 0
    project_client.date_of_birth = date_of_birth
    project_client.ssn = ssn
    project_client.days_literally_homeless_in_last_three_years = days_homeless_in_the_last_three_years
    project_client.veteran_status = 1 if veteran
    project_client.rrh_desired = rrh_desired
    project_client.youth_rrh_desired = youth_rrh_desired
    project_client.rrh_assessment_contact_info = rrh_assessment_contact_info if income_maximization_assistance_requested

    project_client.required_number_of_bedrooms = required_number_of_bedrooms
    project_client.required_minimum_occupancy = required_minimum_occupancy
    project_client.requires_wheelchair_accessibility = requires_wheelchair_accessibility
    project_client.requires_elevator_access = requires_elevator_access
    project_client.family_member = family_member

    project_client.housing_release_status = _('Full HAN Release') if full_release_on_file

    project_client.calculated_chronic_homelessness = calculated_chronic_homelessness
    project_client.middle_name = middle_name
    project_client.gender = gender

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
