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
  delegate :contacts_editable_by_hsa, to: :match_route
  has_one :program, through: :sub_program
  has_one :sub_program, through: :opportunity
  has_one :match_route, through: :program

  has_many :notifications, class_name: 'Notifications::Base'

  # Default Match Route
  has_decision :match_recommendation_dnd_staff
  has_decision :match_recommendation_shelter_agency
  has_decision :confirm_shelter_agency_decline_dnd_staff
  has_decision :schedule_criminal_hearing_housing_subsidy_admin
  has_decision :approve_match_housing_subsidy_admin
  has_decision :confirm_housing_subsidy_admin_decline_dnd_staff
  has_decision :record_client_housed_date_shelter_agency # Legacy decision type as of 10/16/2016
  has_decision :record_client_housed_date_housing_subsidy_administrator
  has_decision :confirm_match_success_dnd_staff

  # Provider Only Match Route
  # NB: the following class names need to be strings, or it has trouble finding the nested StatusCallback classes
  has_decision :hsa_acknowledges_receipt, decision_class_name: 'MatchDecisions::ProviderOnly::HsaAcknowledgesReceipt', notification_class_name: 'Notifications::ProviderOnly::MatchInitiationForHsa'
  has_decision :hsa_accepts_client, decision_class_name: 'MatchDecisions::ProviderOnly::HsaAcceptsClient', notification_class_name: 'Notifications::ProviderOnly::HsaAcceptsClient'
  has_decision :confirm_hsa_accepts_client_decline_dnd_staff, decision_class_name: 'MatchDecisions::ProviderOnly::ConfirmHsaAcceptsClientDeclineDndStaff', notification_class_name: 'Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff'

  has_one :current_decision

  CLOSED_REASONS = ['success', 'rejected', 'canceled']
  validates :closed_reason, inclusion: {in: CLOSED_REASONS, if: :closed_reason}

  scope :on_route, -> (route) do
    joins(:program).merge(Program.on_route(route))
  end

  ###################
  ## Life cycle Scopes
  ###################

  scope :proposed, -> { where active: false, closed: false }
  scope :candidate, -> { proposed } #alias
  scope :active, -> { where active: true  }
  scope :closed, -> { where closed: true }
  scope :open, -> { where closed: false }
  scope :successful, -> { where closed: true, closed_reason: 'success' }
  scope :success, -> {successful} # alias
  scope :rejected, -> { where closed: true, closed_reason: 'rejected' }
  scope :preempted, -> { where closed: true, closed_reason: 'canceled' }
  scope :canceled, -> { preempted } # alias
  scope :stalled, -> do
    ids = Set.new
    MatchRoutes::Base.all_routes.each do |route|
      # instantiate the route
      route = route.first
      stall_date = route.stalled_interval.days.ago
      ids += active.on_route(route).joins(:decisions).merge(
        MatchDecisions::Base.awaiting_action.last_updated_before(stall_date)
      ).distinct.pluck(:id)
    end
    where(id: ids.to_a)
  end
  scope :hsa_involved, -> do # any match where the HSA has participated, or has been asked to participate
    md_t = MatchDecisions::Base.arel_table
    joins(:decisions).
    where(
      md_t[:status].eq('accepted').and(md_t[:type].eq('MatchDecisions::MatchRecommendationShelterAgency')).
      or(
        md_t[:status].eq('decline_overridden').and(md_t[:type].eq('MatchDecisions::ConfirmShelterAgencyDeclineDndStaff'))
      )
    )
  end
  scope :should_alert_warehouse, -> do
    success.joins(:match_route).merge(MatchRoutes::Base.should_cancel_other_matches)
  end

  scope :in_process_or_complete, -> do
    where(arel_table[:active].eq(true).or(arel_table[:closed].eq(true)))
  end


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

    has_many :hsp_contacts,
    -> { where client_opportunity_match_contacts: {hsp: true} },
    class_name: 'Contact',
    through: :client_opportunity_match_contacts,
    source: :contact

  has_many :events,
    class_name: 'MatchEvents::Base',
    foreign_key: :match_id,
    inverse_of: :match,
    dependent: :destroy

  has_one :match_created_event,
    class_name: MatchEvents::Created.name,
    foreign_key: :match_id

  has_many :note_events,
    class_name: MatchEvents::Note.name,
    foreign_key: :match_id

  has_many :status_updates,
    class_name: MatchProgressUpdates::Base.name,
    foreign_key: :match_id

  def self.closed_filter_options
    {
      'Success' => 'success',
      'Rejected/Declined' =>'rejected',
      'Canceled/Pre-Empted' => 'canceled'
    }
  end

  def confidential?
    program&.confidential? || client&.confidential? || sub_program&.confidential? || ! client&.has_full_housing_release?
  end

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
    elsif contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa && client&.has_full_housing_release?
      true
    elsif (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && (shelter_agency_approval_or_dnd_override? && client&.has_full_housing_release?)
      true
    else
      false
    end
  end

  def can_see_match_yet? contact
    return false unless contact
    if contact.user_can_view_all_clients?
      true
    elsif contact.in?(shelter_agency_contacts)
      true
    elsif contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa
      true
    elsif (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && (shelter_agency_approval_or_dnd_override?)
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
      "(name withheld — #{id})"
    end
  end

  def shelter_agency_approval_or_dnd_override?
    hsa_involved?
  end

  def hsa_involved?
    self.class.hsa_involved.where(id: id).exists?
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
      or(contact_matches).
      or(arel_table[:id].eq(text))
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
    add_default_hsp_contacts!
  end

  def self.contact_titles
    {
      shelter_agency_contacts: "#{_('Shelter Agency')} Contacts",
      housing_subsidy_admin_contacts: "#{_('Housing Subsidy Administrators')}",
      ssp_contacts: "#{_('Stabilization Service Providers')}",
      hsp_contacts: "#{_('Housing Search Providers')}",
    }
  end

  def contact_titles
    self.class.contact_titles
  end

  def overall_status
    if active?
      if status_declined?
        {name: 'Declined', type: 'danger'}
      else
        {name: 'In Progress', type: 'success'}
      end

    elsif closed?
      case closed_reason
      when 'success' then {name: 'Success', type: 'success'}
      when 'rejected' then {name: 'Rejected', type: 'danger'}
      when 'canceled' then {name: 'Pre-empted', type: 'danger'}
      end
    else
       {name: 'New', type: 'success'}

    end

  end

  def status_declined?
    dnd_status = match_recommendation_dnd_staff_decision&.status
    shelter_status = match_recommendation_shelter_agency_decision&.status
    shelter_override_status = confirm_shelter_agency_decline_dnd_staff_decision&.status
    shelter_declined = (shelter_status == 'declined' && ! shelter_override_status == 'decline_overridden')
    hsa_status = approve_match_housing_subsidy_admin_decision&.status
    hsa_override_status = confirm_housing_subsidy_admin_decline_dnd_staff_decision&.status
    hsa_declined = (hsa_status == 'declined' && ! hsa_override_status == 'decline_overridden')
    dnd_status == 'decline' || shelter_declined || hsa_declined
  end

  def stalled?
    self.class.stalled.where(id: id).exists?
  end

  def successful?
    closed? && closed_reason == 'success'
  end

  def current_step_name
    current_decision.step_name if active?
  end

  def timeline_events
    event_history = events.preload(:notification, :contact, decision: [:decline_reason, :not_working_with_client_reason]).all.to_a
    status_history = status_updates.complete.preload(:notification, :contact).to_a
    event_history + status_history
  end

  def can_create_overall_note? contact
    can_create_administrative_note?(contact) || contact&.user&.can_create_overall_note?
  end

  def can_create_administrative_note? contact
    contact.present? && (contact.user.present? && (contact.user.can_approve_matches? || contact.user.can_reject_matches?))
  end

  def match_contacts
    @match_contacts ||= MatchContacts.new match: self
  end

  def progress_update_contact_ids
    match_contacts&.progress_update_contact_ids
  end


  def expire_all_notifications(on: 1.week.from_now.to_date)
    notifications.update_all(expires_at: on)
  end

  def activate!
    self.class.transaction do
      update! active: true
      client.make_unavailable_in(match_route: opportunity.match_route)
      opportunity.update available_candidate: false
      add_default_contacts!
      self.send(match_route.initial_decision).initialize_decision!
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
    end
  end

  def rejected!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'rejected'
      client.make_available_in(match_route: opportunity.match_route)
      opportunity.update! available_candidate: opportunity.active_match.blank?
      RejectedMatch.create! client_id: client.id, opportunity_id: opportunity.id
      Matching::RunEngineJob.perform_later
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications()
    end
  end

  def canceled!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'canceled'
      client.make_available_in(match_route: opportunity.match_route)
      opportunity.update! available_candidate: opportunity.active_match.blank?
      RejectedMatch.create! client_id: client.id, opportunity_id: opportunity.id
      Matching::RunEngineJob.perform_later
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications()
    end
  end

  # Similar to a cancel, but allow the client to re-match the same opportunity
  # if it comes up again.  Also, don't re-run the matching engine, we'll
  # put the opportunity
  def poached!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'canceled'
      client.make_available_in(match_route: opportunity.match_route)
      opportunity.update! available_candidate: false
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications()
    end
  end

  def succeeded!
    self.class.transaction do
      route = opportunity.match_route
      update! active: false, closed: true, closed_reason: 'success'
      if route.should_cancel_other_matches
        client_related_matches.destroy_all
        client.update available: false
        # Prevent matching on any route
        client.make_unavailable_in_all_routes
      else
        # Prevent matching on this route again
        client.make_available_in match_route: route
      end

      opportunity_related_matches.destroy_all
      opportunity.update available: false, available_candidate: false
      if opportunity.unit != nil
        opportunity.unit.update available: false
      end
      if opportunity.voucher.present?
        opportunity.voucher.update available: false, skip_match_locking_validation: true
        opportunity.voucher.sub_program.update_summary!
      end
      # Prevent access to this match by notification after 1 week
      expire_all_notifications()
    end
  end

  def client_related_matches
    ClientOpportunityMatch.open.joins(:match_route).
      where(client_id: client_id).
      where.not(id: id)
  end

  def opportunity_related_matches
    ClientOpportunityMatch.
      where(opportunity_id: opportunity_id).
      where.not(id: id)
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
      program.dnd_contacts.each do |contact|
        assign_match_role_to_contact :dnd_staff, contact
      end
    end

    def add_default_housing_subsidy_admin_contacts!
      opportunity.housing_subsidy_admin_contacts.each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
      program.housing_subsidy_admin_contacts.each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
      # If for some reason we forgot to setup the default HSA contacts
      # put the people who usually receive initial notifications in that role
      if contacts_editable_by_hsa && housing_subsidy_admin_contacts.blank?
        Contact.where(user_id: User.dnd_initial_contact.select(:id)).each do |contact|
          assign_match_role_to_contact :housing_subsidy_admin, contact
        end
      end

    end

    def add_default_client_contacts!
      client.regular_contacts.each do |contact|
        assign_match_role_to_contact :client, contact
      end
      program.client_contacts.each do |contact|
        assign_match_role_to_contact :client, contact
      end
    end

    def add_default_shelter_agency_contacts!
      client.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
      program.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
    end

    def add_default_ssp_contacts!
      program.ssp_contacts.each do |contact|
        assign_match_role_to_contact :ssp, contact
      end
    end

    def add_default_hsp_contacts!
      program.hsp_contacts.each do |contact|
        assign_match_role_to_contact :hsp, contact
      end
    end

    def self.delinquent_match_ids
      columns = [:contact_id, :match_id, :requested_at, :submitted_at]
      updates = MatchProgressUpdates::Base.joins(:contact).
        where(match_id: self.stalled.select(:id)).
        pluck(*columns).map do |row|
          Hash[columns.zip(row)]
        end.group_by do |row|
          row[:match_id]
        end

      updates.map do |match_id, update_requests|
        delinquent = Set.new
        requests_by_contact = update_requests.group_by do |row|
          row[:contact_id]
        end
        requests_by_contact.each do |contact_id, contact_requests|
          contact_requests.each do |row|
            if row[:submitted_at].blank? && row[:requested_at].present? && row[:requested_at] <= Date.today
              delinquent << contact_id
            end
          end
        end
        # if every contact is delinquent, show the match
        if delinquent.size == requests_by_contact.size
          match_id
        else
          nil
        end
      end.compact
    end

    def self.at_least_one_response_in_current_iteration_ids
      columns = [:contact_id, :match_id, :requested_at, :submitted_at]
      updates = MatchProgressUpdates::Base.joins(:contact).
        where(match_id: self.stalled.select(:id)).
        order(requested_at: :asc).
        pluck(*columns).map do |row|
          Hash[columns.zip(row)]
        end.group_by do |row|
          row[:match_id]
        end

      updates.map do |match_id, update_requests|
        submitted_most_recent = false
        requests_by_contact = update_requests.group_by do |row|
          row[:contact_id]
        end.each do |contact_id, contact_requests|
          if contact_requests.last[:submitted_at].present?
            submitted_most_recent = true
          end
        end
        if submitted_most_recent
          match_id
        else
          nil
        end
      end.compact
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
        {title: 'Most served', column: 'days_homeless', direction: 'desc'},
        {title: 'Most served in last three years', column: 'days_homeless_in_last_three_years', direction: 'desc'},
        {title: 'Current step', column: 'current_step', direction: 'desc'},
        {title: 'Initial Acceptance Expiration Date', column: 'shelter_expiration', direction: 'asc'},
        {title: 'VI-SPDAT Score', column: 'vispdat_score', direction: 'desc'},
        {title: 'Priority Score', column: 'vispdat_priority_score', direction: 'desc'},
      ]
    end

end
