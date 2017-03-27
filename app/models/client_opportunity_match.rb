class ClientOpportunityMatch < ActiveRecord::Base
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include ClientOpportunityMatches::HasDecisions

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self, nil, 'match')
  end

  acts_as_paranoid
  has_paper_trail

  after_create :create_match_created_event!

  belongs_to :client
  belongs_to :opportunity
  delegate :opportunity_details, to: :opportunity, allow_nil: true
  delegate :program, to: :sub_program
  delegate :sub_program, to: :opportunity
  delegate :confidential?, to: :program

  has_many :notifications, class_name: 'Notifications::Base'

  has_decision :match_recommendation_dnd_staff
  has_decision :match_recommendation_shelter_agency
  has_decision :confirm_shelter_agency_decline_dnd_staff
  has_decision :schedule_criminal_hearing_housing_subsidy_admin
  has_decision :approve_match_housing_subsidy_admin
  has_decision :confirm_housing_subsidy_admin_decline_dnd_staff
  has_decision :record_client_housed_date_shelter_agency # Legacy decision type as of 10/16/2016
  has_decision :record_client_housed_date_housing_subsidy_administrator
  has_decision :confirm_match_success_dnd_staff

  CLOSED_REASONS = ['success', 'rejected', 'preempted']
  validates :closed_reason, inclusion: {in: CLOSED_REASONS, if: :closed_reason}

  ###################
  ## Lifecycle Scopes
  ###################

  scope :proposed, -> { where active: false, closed: false }
  scope :candidate, -> { proposed } #alias
  scope :active, -> { where active: true  }
  scope :closed, -> { where closed: true }
  scope :successful, -> { where closed: true, closed_reason: 'success' }
  scope :rejected, -> { where closed: true, closed_reason: 'rejected' }
  scope :preempted, -> { where closed: true, closed_reason: 'preempted' }


  ######################
  # Contact Associations
  ######################

  # All Contacts
  has_many :client_opportunity_match_contacts, dependent: :destroy, inverse_of: :match, foreign_key: 'match_id'
  has_many :contacts, through: :client_opportunity_match_contacts

  # filtered by role
  has_many :dnd_staff_contacts,
    -> { where client_opportunity_match_contacts: {dnd_staff: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :housing_subsidy_admin_contacts,
    -> { where client_opportunity_match_contacts: {housing_subsidy_admin: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :client_contacts,
    -> { where client_opportunity_match_contacts: {client: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :shelter_agency_contacts,
    -> { where client_opportunity_match_contacts: {shelter_agency: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :ssp_contacts,
    -> { where client_opportunity_match_contacts: {ssp: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :events,
    class_name: 'MatchEvents::Base',
    foreign_key: :match_id,
    inverse_of: :match,
    dependent: :destroy

  has_one :match_created_event,
    class_name: 'MatchEvents::Created',
    foreign_key: :match_id

  has_many :note_events,
    class_name: 'MatchEvents::Note',
    foreign_key: :match_id

  def self.accessible_by_user user
    # admins & DND see everything
    if user.can_view_all_matches?
      all
    # Allow logged-in users to see any match they are a contact on
    elsif user.present?
      contact = user.contact
      subquery = ClientOpportunityMatchContact
        .where(contact_id: contact.id)
        .select(:match_id)
      where(id: subquery)
    else
      none
    end
  end

  def show_client_info_to? contact
    return false unless contact
    if contact.user_can_view_all_clients?
      true
    elsif contact.in?(shelter_agency_contacts)
      true
    elsif (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts)) && shelter_agency_approval_or_dnd_override?
      true
    else
      false
    end
  end

  def client_name_for_contact contact, hidden:
    if hidden
      '(name hidden)'
    elsif show_client_info_to?(contact)
      client.full_name
    else
      '(name withheld)'
    end
  end

  private def shelter_agency_approval_or_dnd_override?
    match_recommendation_shelter_agency_decision.status == 'accepted' ||
      confirm_shelter_agency_decline_dnd_staff_decision.status == 'decline_overridden'
  end

  def self.text_search(text)
    return none unless text.present?

    client_matches = Client.where(
      Client.arel_table[:id].eq arel_table[:client_id]
    ).text_search(text).exists

    opp_matches = Opportunity.where(
      Opportunity.arel_table[:id].eq arel_table[:opportunity_id]
    ).text_search(text).exists


    contact_matches = ClientOpportunityMatchContact.where(
      ClientOpportunityMatchContact.arel_table[:match_id].eq(arel_table[:id])
    ).text_search(text).exists
    
    where(
      client_matches.
      or(opp_matches).
      or(contact_matches)
    )
  end

  def self.associations_adding_requirements
    [:opportunity]
  end

  def self.associations_adding_services
    [:opportunity]
  end

  # returns the most recent decision
  def current_decision
    unless closed?
      initialized_decisions.order(created_at: :desc).first
    end
  end

  def add_default_contacts!
    add_default_dnd_staff_contacts!
    add_default_housing_subsidy_admin_contacts!
    add_default_client_contacts!
    add_default_shelter_agency_contacts!
    add_default_ssp_contacts!
  end

  def overall_status
    if active?
      if match_recommendation_dnd_staff_decision.status == 'decline' ||
        (match_recommendation_shelter_agency_decision.status == 'declined' && ! confirm_shelter_agency_decline_dnd_staff_decision.status == 'decline_overridden') ||
        (approve_match_housing_subsidy_admin_decision.status == 'declined' && ! confirm_housing_subsidy_admin_decline_dnd_staff_decision.status == 'decline_overridden')
        "Declined"
      else
        "In Progress"
      end
    elsif closed?
      case closed_reason
      when 'success' then 'Success'
      when 'rejected' then 'Rejected'
      when 'preempted' then 'Pre-empted'
      end
    else
      'New'
    end
  end

  def successful?
    closed? && closed_reason == 'success'
  end

  def current_step_name
    current_decision.step_name if active?
  end

  def timeline_events
    events.preload(:notification, :contact, decision: [:decline_reason, :not_working_with_client_reason]).all
  end

  def can_create_overall_note? contact
    contact && (contact.user && contact.user.can_approve_matches? || contact.user.can_reject_matches?)
  end

  def match_contacts
    @match_contacts ||= MatchContacts.new match: self
  end

  def activate!
    self.class.transaction do
      update! active: true
      client.update available_candidate: false
      opportunity.update available_candidate: false
      add_default_contacts!
      match_recommendation_dnd_staff_decision.initialize_decision!
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
    end
  end

  def rejected!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'rejected'
      client.update! available_candidate: true
      opportunity.update! available_candidate: true
      RejectedMatch.create! client_id: client.id, opportunity_id: opportunity.id
      Matching::RunEngineJob.perform_later
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
    end
  end

  def succeeded!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'success'
      client_related_matches.destroy_all
      opportunity_related_matches.destroy_all
      client.update available: false, available_candidate: false
      opportunity.update available: false, available_candidate: false
      if opportunity.unit != nil
        opportunity.unit.update available: false
      end
      if opportunity.voucher.present?
        opportunity.voucher.update available: false, skip_match_locking_validation: true
        opportunity.voucher.sub_program.update_summary!
      end
    end
  end

  def client_related_matches
    ClientOpportunityMatch
      .where(client_id: client_id)
      .where.not(id: id)
  end

  def opportunity_related_matches
    ClientOpportunityMatch
      .where(opportunity_id: opportunity_id)
      .where.not(id: id)
  end

  private

    def assign_match_role_to_contact role, contact
      join_model = client_opportunity_match_contacts.detect do |match_contact|
        match_contact.contact_id == contact.id
      end
      join_model ||= client_opportunity_match_contacts.build contact: contact
      join_model.send("#{role}=", true)
      join_model.save
    end

    def add_default_dnd_staff_contacts!
      Contact.where(user_id: User.dnd_initial_contact.select(:id)).each do |contact|
        assign_match_role_to_contact :dnd_staff, contact
      end
    end

    def add_default_housing_subsidy_admin_contacts!
      opportunity.housing_subsidy_admin_contacts.each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
    end

    def add_default_client_contacts!
      client.regular_contacts.each do |contact|
        assign_match_role_to_contact :client, contact
      end
    end

    def add_default_shelter_agency_contacts!
      client.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
    end

    def add_default_ssp_contacts!
      
    end

    def self.sort_options
      [
        {title: 'Oldest match', column: 'created_at', direction: 'asc'},
        {title: 'Most recent match', column: 'created_at', direction: 'desc'},
        {title: 'Last name A-Z', column: 'last_name', direction: 'asc'},
        {title: 'Last name Z-A', column: 'last_name', direction: 'desc'},
        {title: 'First name A-Z', column: 'first_name', direction: 'asc'},
        {title: 'First name Z-A', column: 'first_name', direction: 'desc'},
        {title: 'Recently changed', column: 'last_decision', direction: 'desc'},
        {title: 'Longest standing client', column: 'calculated_first_homeless_night', direction: 'asc'},
        {title: 'Current step', column: 'current_step', direction: 'desc'},
        {title: 'Initial Acceptance Expiration Date', column: 'shelter_expiration', direction: 'asc'},
      ]
    end

end
