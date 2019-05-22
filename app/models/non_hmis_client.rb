class NonHmisClient < ActiveRecord::Base
  has_one :project_client, ->  do
    where(
        data_source_id: DataSource.where(db_identifier: NonHmisClient.ds_identifier).select(:id),
    )
  end, foreign_key: :id_in_data_source, required: false
  has_one :client, through: :project_client, required: false
  has_many :client_opportunity_matches, through: :client

  has_paper_trail
  acts_as_paranoid

  scope :available, -> do
    where(available: true)
  end

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

  scope :family_member, -> (status) do
    where(family_member: status)
  end

  def self.age date:, dob:
    return unless date.present? && dob.present?
    age = date.year - dob.year
    age -= 1 if dob > date.years_ago(age)
    return age
  end

  def age date=Date.today
    return unless date_of_birth.present?
    date = date.to_date
    dob = date_of_birth.to_date
    self.class.age(date: date, dob: dob)
  end
  alias_method :age_on, :age

  def involved_in_match?
    client_opportunity_matches.exists?
  end

  def cohort_names
    return '' unless Warehouse::Base.enabled?
    Warehouse::Cohort.active.where(id: self.active_cohort_ids).pluck(:name).join("\n")
  end

  # Sorting and Searching

  scope :search_first_name, -> (name) do
    arel_table[:first_name].lower.matches("%#{name.downcase}%")
  end
  scope :search_last_name, -> (name) do
    arel_table[:last_name].lower.matches("%#{name.downcase}%")
  end
  scope :search_alternate_name, -> (name) do
    arel_table[:client_identifier].lower.matches("%#{name.downcase}%")
  end

  def self.ransackable_scopes(auth_object = nil)
    [:text_search]
  end

  def self.possible_agencies
    User.distinct.pluck(:agency).compact
  end

  def self.possible_cohorts
    return [] unless Warehouse::Base.enabled?
    Warehouse::Cohort.active.visible_in_cas.pluck(:id, :name).to_h
  end

  def populate_project_client project_client
    set_project_client_fields project_client
    project_client.save
  end

  def set_project_client_fields project_client
    project_client.first_name = first_name
    project_client.last_name = last_name
    project_client.active_cohort_ids = active_cohort_ids
    project_client.assessment_score = assessment_score || 0
    project_client.date_of_birth = date_of_birth
    project_client.ssn = ssn
    project_client.days_homeless_in_last_three_years = days_homeless_in_the_last_three_years
    project_client.days_literally_homeless_in_last_three_years = days_homeless_in_the_last_three_years
    project_client.days_homeless = days_homeless_in_the_last_three_years
    project_client.date_days_homeless_verified = date_days_homeless_verified
    project_client.who_verified_days_homeless = who_verified_days_homeless

    project_client.veteran_status = 1 if veteran
    project_client.rrh_desired = rrh_desired
    project_client.youth_rrh_desired = youth_rrh_desired
    project_client.rrh_assessment_contact_info = rrh_assessment_contact_info
    project_client.required_number_of_bedrooms = required_number_of_bedrooms
    project_client.required_minimum_occupancy = required_minimum_occupancy
    project_client.requires_wheelchair_accessibility = requires_wheelchair_accessibility
    project_client.requires_elevator_access = requires_elevator_access
    project_client.family_member = family_member

    project_client.housing_release_status = _('Full HAN Release') if full_release_on_file

    project_client.calculated_chronic_homelessness = calculated_chronic_homelessness
    project_client.middle_name = middle_name
    project_client.gender = gender
    project_client.neighborhood_interests = neighborhood_interests
    project_client.interested_in_set_asides = interested_in_set_asides

    project_client.income_total_monthly = income_total_monthly
    project_client.disabling_condition = if disabling_condition then 1 else nil end
    project_client.physical_disability = if physical_disability then 1 else nil end
    project_client.developmental_disability = if developmental_disability then 1 else nil end
    project_client.domestic_violence = 1 if domestic_violence

    project_client.tags = cas_tags

    project_client.sync_with_cas = self.available
    project_client.needs_update = true
  end

  def log message
    Rails.logger.info message
  end

  def cas_tags
    @cas_tags = {}
    Tag.where(rrh_assessment_trigger: true).each do |tag|
      @cas_tags[tag.id] = assessment_score if assessment_score.present?
    end
    return @cas_tags
  end

  def update_project_clients_from_non_hmis_clients
    data_source_id = DataSource.where(db_identifier: self.class.ds_identifier).pluck(:id).first

    # remove unused ProjectClients
    ProjectClient.where(
        data_source_id: data_source_id).
        where.not(id_in_data_source: NonHmisClient.select(:id)).
        delete_all

    # update or add clients
    client_scope.each do |client|
      project_client = ProjectClient.where(
          data_source_id: data_source_id,
          id_in_data_source: client.id
      ).first_or_initialize
      client.populate_project_client(project_client)
    end

    log "Updated #{client_scope.count} ProjectClients from #{self.class.name}"
  end

  def client_scope
    raise NotImplementedError
  end

  def self.ds_identifier
    'Deidentified'
  end

  def download_data
    raise NotImplementedError
  end

  def download_headers
    raise NotImplementedError
  end

end
