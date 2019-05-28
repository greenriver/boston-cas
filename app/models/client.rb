class Client < ActiveRecord::Base
  before_create :assign_tie_breaker

  include SubjectForMatches
  include MatchArchive
  include Availability

  has_paper_trail
  acts_as_paranoid

  belongs_to :ethnicity, foreign_key: :ethnicity_id, primary_key: :numeric
  belongs_to :race, foreign_key: :race_id, primary_key: :numeric
  belongs_to :veteran_status, foreign_key: :veteran_status_id, primary_key: :numeric
  belongs_to :gender, foreign_key: :gender_id, primary_key: :numeric

  has_one :project_client, primary_key: :id, foreign_key: :client_id
  has_many :building_clients

  # all contacts
  has_many :client_contacts, dependent: :destroy, inverse_of: :client
  has_many :contacts, through: :client_contacts

  has_many :regular_client_contacts, -> { where regular: true},
    class_name: 'ClientContact'
  has_many :regular_contacts,
    through: :regular_client_contacts,
    source: :contact

  has_many :shelter_agency_client_contacts, -> { where shelter_agency: true},
           class_name: 'ClientContact'
  has_many :shelter_agency_contacts,
           through: :shelter_agency_client_contacts,
           source: :contact

  has_many :dnd_staff_client_contacts, -> { where dnd_staff: true},
           class_name: 'ClientContact'
  has_many :dnd_staff_contacts,
           through: :dnd_staff_client_contacts,
           source: :contact

  has_many :housing_subsidy_admin_client_contacts, -> { where housing_subsidy_admin: true},
           class_name: 'ClientContact'
  has_many :housing_subsidy_admin_contacts,
           through: :housing_subsidy_admin_client_contacts,
           source: :contact

  has_many :hsp_client_contacts, -> { where hsp: true},
           class_name: 'ClientContact'
  has_many :hsp_contacts,
           through: :hsp_client_contacts,
           source: :contact

  has_many :ssp_client_contacts, -> { where ssp: true},
           class_name: 'ClientContact'
  has_many :ssp_contacts,
           through: :ssp_client_contacts,
           source: :contact

  has_many :do_client_contacts, -> { where do: true},
           class_name: 'ClientContact'
  has_many :do_contacts,
           through: :do_client_contacts,
           source: :contact

  has_many :client_notes, inverse_of: :client

  has_many :unavailable_as_candidate_fors

  validates :ssn, length: {maximum: 9}

  scope :parked, -> { where(['prevent_matching_until > ?', Date.today]) }
  scope :not_parked, -> do
    where(['prevent_matching_until is null or prevent_matching_until < ?', Date.today])
  end
  scope :available_for_matching, -> (match_route)  do
    # anyone who hasn't been matched fully, isn't parked
    available_clients = available.available_as_candidate(match_route).not_parked
    # and unless allowed by the route, isn't active in another match
    if match_route.should_prevent_multiple_matches_per_client
      available_clients.where.not(
        id: ClientOpportunityMatch.active.
          on_route(match_route).
          joins(:client).select(arel_table[:id])
      )
    else
      available_clients
    end
  end

  scope :available_as_candidate, -> (match_route) do
    where.not(id: UnavailableAsCandidateFor.for_route(match_route).select(:client_id))
  end

  scope :active_in_match, -> {
    joins(:client_opportunity_matches).merge(ClientOpportunityMatch.active)
  }
  scope :available, -> {
    where(available: true)
  }
  scope :unavailable, -> {
    where(available: false)
  }
  scope :available, -> do
    where(available: true)
  end

  scope :unavailable_in, -> (route) do
    joins(:unavailable_as_candidate_fors).merge(UnavailableAsCandidateFor.for_route(route))
  end
  # scope :fully_matched, -> {
  #   where(available_candidate: false).
  #   where.not(id: active_in_match.select(:id))
  # }

  scope :veteran, -> { where(veteran: true)}
  scope :non_veteran, -> { where(veteran: false)}
  scope :confidential, -> { where(confidential: true) }
  scope :non_confidential, -> { where(confidential: false) }
  scope :full_release, -> { where(housing_release_status: 'Full HAN Release') }

  scope :search_alternate_name, -> (name) do
    arel_table[:alternate_names].lower.matches("%#{name.downcase}%")
  end
  scope :search_first_name, -> (name) do
    arel_table[:first_name].lower.matches("%#{name.downcase}%")
  end
  scope :search_last_name, -> (name) do
    arel_table[:last_name].lower.matches("%#{name.downcase}%")
  end

  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    sa = arel_table
    numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = /\d\d\/\d\d\/\d\d\d\d/.match(text).try(:[], 0) == text
    social = /\d\d\d-\d\d-\d\d\d\d/.match(text).try(:[], 0) == text
    # Explicitly search for only last, first if there's a comma in the search
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
      if last.present?
        where = search_last_name(last).or(search_alternate_name(last))
      end
      if last.present? && first.present?
        where = where.and(search_first_name(first)).or(search_alternate_name(first))
      elsif first.present?
        where = search_first_name(first).or(search_alternate_name(first))
      end
    # Explicity search for "first last"
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
      where = search_first_name(first)
        .and(search_last_name(last))
        .or(search_alternate_name(first))
        .or(search_alternate_name(last))
    # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.gsub('-',''))
    elsif date
      (month, day, year) = text.split('/')
      where = sa[:date_of_birth].eq("#{year}-#{month}-#{day}")
    else
      query = "%#{text}%"
      where = search_first_name(text)
        .or(search_last_name(text))
        .or(sa[:ssn].matches(query))
        .or(search_alternate_name(text))
    end
    where(where)
  end

  def self.ransackable_scopes(auth_object = nil)
    [:text_search]
  end

  def full_name
    [first_name, middle_name, last_name, name_suffix].select{|n| n.present?}.join(' ')
  end
  alias_method :name, :full_name

  def client_name_for_contact contact, hidden:
    if hidden
      '(name hidden)'
    elsif contact.user_can_view_all_clients?
      full_name
    else
      "(name withheld)"
    end
  end

  def default_client_contacts
    @default_client_contacts ||= ClientContacts.new client: self
  end

  def self.prioritized(match_route, scope)
    match_route.match_prioritization.prioritization_for_clients(scope)
  end

  # A random number for prioritizations that require a tie-breaker
  def assign_tie_breaker
    tie_breaker = rand
  end

  def self.add_missing_tie_breakers
    c_t = Client.arel_table
    update = Arel::UpdateManager.new(c_t.engine)
    update.table(c_t)
    update.set([[c_t[:tie_breaker], Arel.sql('random()')]]).where(c_t[:tie_breaker].eq(nil))
    result = ActiveRecord::Base.connection.execute(update.to_sql)
    log "Updated #{result.cmd_tuples} clients with missing tie_breakers"
  end

  def self.ready_to_match match_route:
    available_as_candidate(match_route).matchable
  end

  def self.max_candidate_matches
    6
  end

  def self.randomize_pii
    all.each do |c|
      c.first_name = Faker::Name.first_name
      c.middle_name = Faker::Boolean.boolean(0.10) ? Faker::Name.last_name : nil
      c.last_name = Faker::Name.last_name
      c.name_suffix = ''
      c.ssn = Faker::Number.number(9)
      c.date_of_birth = Faker::Date.between(80.years.ago, 25.years.ago)
      c.homephone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.cellphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.workphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.pager = ''
      c.email = ''
      c.save(validate: false)
    end
  end

  def self.accessible_by_user(user)
    if user.can_view_all_clients?
      all
    else
      none
    end
  end

  def accessible_by_user?(user)
    if user.can_view_all_clients?
      true
    else
      false
    end
  end

  def non_hmis?
    NonHmisClient.joins(:client).merge(Client.where(id: id)).exists?
  end

  def merged_with_name
    c = Client.find(merged_into)
    c.full_name
  end

  def previously_merged?
    count = Client.where(merged_into: id).pluck(id).length
    if count > 0
      return true
    end
    return false
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

  def cohorts
    return [] unless Warehouse::Base.enabled?
    Warehouse::Cohort.visible_in_cas.where(id: active_cohort_ids)
  end

  def rank_for_tag match_route:
    tag_id = match_route.tag_id
    tags.try(:[], tag_id.to_s)
  end

  def prioritized_matches
    o_t = Opportunity.arel_table
    client_opportunity_matches.joins(:opportunity).order(o_t[:matchability].asc)
  end

  def housing_history
    #client_opportunity_matches.inspect
  end

  def match_for_opportunity(opportunity)
    client_opportunity_matches.active.where(opportunity: opportunity).first
  end

  # def active_in_match
  #   client_opportunity_matches.active.first
  # end

  def active_matches
    client_opportunity_matches.active
  end

  def active_in_match?
    client_opportunity_matches.active.exists?
  end

  def available_as_candidate_for_any_route?
    (
      MatchRoutes::Base.available.pluck(:type) -
      UnavailableAsCandidateFor.where(client_id: id).distinct.pluck(:match_route_type)
    ).any?
  end

  def make_available_in match_route:
    route_name = MatchRoutes::Base.route_name_from_route(match_route)
    UnavailableAsCandidateFor.where(client_id: id, match_route_type: route_name).destroy_all
  end

  def make_available_in_all_routes
    UnavailableAsCandidateFor.where(client_id: id).destroy_all
  end

  def make_unavailable_in match_route:
    route_name = MatchRoutes::Base.route_name_from_route(match_route)
    unavailable_as_candidate_fors.create(match_route_type: route_name)
  end

  def make_unavailable_in_all_routes
    MatchRoutes::Base.all_routes.each do |route|
      make_unavailable_in match_route: route
    end
  end

  def unavailable(permanent:false, contact_id:nil)
    active_match = client_opportunity_matches.active.first
    Client.transaction do
      if active_match.present?
        opportunity = active_match.opportunity
        active_match.canceled!
        MatchEvents::Parked.create!(
            match_id: active_match.id,
            contact_id: contact_id
        )
        opportunity.update(available_candidate: true)
        Matching::RunEngineJob.perform_later
      end
      if client_opportunity_matches.proposed.any?
        client_opportunity_matches.proposed.each do |opp|
          opp.delete
        end
      end
      if permanent
        update(available: false)
      else
        # This will re-queue the client once the date is passed
        MatchRoutes::Base.all_routes.each do |route|
          make_unavailable_in match_route: route
        end
      end
    end
  end

  def remote_id
   @remote_id ||= project_client&.id_in_data_source.presence
  end

  def remote_data_source_id
   @remote_data_source_id ||= project_client&.data_source_id
  end

  def remote_data_source
   @remote_data_source ||= DataSource.find(remote_data_source_id) rescue false
  end

  # Link to the warehouse or other authoritative data source
  # urls should be placed in `data_sources.client_url` and can include :client_id: which will
  # be replaced with Client.remote_id
  # Default URL will use the warehouse setting from the site config
  def data_source_path
   if remote_data_source_id && remote_id
     url = DataSource.where(id: remote_data_source_id).pluck(:client_url).first || Config.get(:warehouse_url) + "/clients/#{remote_id}"
     return url.gsub(':client_id:', remote_id.to_s) if url
   end
  end

  def has_full_housing_release?
    # If we have a warehouse connected, use the file tags available there
    release_tags = if Warehouse::Base.enabled? && remote_data_source.try(:db_identifier) != 'Deidentified'
      Warehouse::AvailableFileTag.full_release.pluck(:name)
    else
      [_('Full HAN Release'), 'Full HAN Release']
    end
    ([_('Full HAN Release')] + release_tags).include? housing_release_status
  end

  # This is only here to allow the translation tool to find it for translating
  def translated_text_of_release_types
    _('Full HAN Release')
    _('Limited CAS Release')
  end

  def self.possible_availability_states
    states = {
      active_in_match: 'Active in a match',
      unavailable: 'Not available',
    }
    # raise 'hi'
    # MatchRoutes::Base.filterable_routes do |title, klass|
    #   states["available_for_matching_on_route_#{key}"] = "Available for matching on #{title}"
    # end
    return states
  end

  def parked?
    prevent_matching_until.present? && prevent_matching_until > Date.today
  end

  def is_available_for_matching?
    if parked?
      return false
    else
      return available
    end
  end

  def available_text
    if is_available_for_matching?
      if available_as_candidate_for_any_route?
        'Available for matching'
      elsif active_in_match?
        'Active in a match'
      else
        'Fully matched'
      end
    else
      if parked?
        "Parked until #{prevent_matching_until}"
      else
        'Not available'
      end
    end
  end

  def has_enrollments?
    self.enrolled_in_th ||
    self.enrolled_in_sh ||
    self.enrolled_in_so ||
    self.enrolled_in_es
  end

  def self.sort_options(show_vispdat: false, show_assessment: false)
    [
      {title: 'Last name A-Z', column: 'last_name', direction: 'asc', order: 'LOWER(last_name) ASC', visible: true},
      {title: 'Last name Z-A', column: 'last_name', direction: 'desc', order: 'LOWER(last_name) DESC', visible: true},
      {title: 'First name A-Z', column: 'first_name', direction: 'asc', order: 'LOWER(first_name) ASC', visible: true},
      {title: 'First name Z-A', column: 'first_name', direction: 'desc', order: 'LOWER(first_name) DESC', visible: true},
      {title: 'Youngest to oldest', column: 'date_of_birth', direction: 'desc', order: 'date_of_birth DESC', visible: true},
      {title: 'Oldest to youngest', column: 'date_of_birth', direction: 'asc', order: 'date_of_birth ASC', visible: true},
      {title: 'Homeless days', column: 'days_homeless', direction: 'desc', order: 'days_homeless DESC', visible: true},
      {title: 'Most served in last three years', column: 'days_homeless_in_last_three_years', direction: 'desc',
          order: 'days_homeless_in_last_three_years DESC', visible: true},
      {title: 'Longest standing', column: 'calculated_first_homeless_night', direction: 'asc',
          order: 'calculated_first_homeless_night ASC', visible: true},
      {title: 'Assessment score', column: 'assessment_score', direction: 'desc', order: 'assessment_score DESC', visible: show_assessment},
      {title: 'VI-SPDAT score', column: 'vispdat_score', direction: 'desc', order: 'vispdat_score DESC', visible: show_vispdat},
      {title: 'Priority score', column: 'vispdat_priority_score', direction: 'desc', order: 'vispdat_priority_score DESC', visible: true}
    ]
  end

  def self.log message
    Rails.logger.info message
  end
end
