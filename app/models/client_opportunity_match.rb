###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ClientOpportunityMatch < ApplicationRecord
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include ClientOpportunityMatches::HasDecisions
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self, nil, 'match')
  end

  acts_as_paranoid
  has_paper_trail

  after_create :create_match_created_event!

  belongs_to :client
  belongs_to :opportunity
  belongs_to :match_route, class_name: 'MatchRoutes::Base'

  delegate :opportunity_details, to: :opportunity, allow_nil: true
  delegate :contacts_editable_by_hsa, to: :match_route
  has_one :sub_program, through: :opportunity
  has_one :program, through: :sub_program

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

  # Set-Asides Match Route
  has_decision :set_asides_hsa_accepts_client, decision_class_name: 'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient', notification_class_name: 'Notifications::HomelessSetAside::HsaAcceptsClient'
  has_decision :set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator, decision_class_name: 'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator', notification_class_name: 'Notifications::RecordClientHousedDateHousingSubsidyAdministrator'
  has_decision :set_asides_confirm_hsa_accepts_client_decline_dnd_staff, decision_class_name: 'MatchDecisions::HomelessSetAside::SetAsidesConfirmHsaAcceptsClientDeclineDndStaff', notification_class_name: 'Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff'

  # Match Route Four
  has_decision :four_match_recommendation_dnd_staff, decision_class_name: 'MatchDecisions::Four::MatchRecommendationDndStaff', notification_class_name: 'Notifications::Four::MatchRecommendationDndStaff'
  has_decision :four_match_recommendation_shelter_agency, decision_class_name: 'MatchDecisions::Four::MatchRecommendationShelterAgency', notification_class_name: 'Notifications::Four::MatchRecommendationShelterAgency'
  has_decision :four_confirm_shelter_agency_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmShelterAgencyDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmShelterAgencyDeclineDndStaff'
  has_decision :four_match_recommendation_hsa, decision_class_name: 'MatchDecisions::Four::MatchRecommendationHsa', notification_class_name: 'Notifications::Four::MatchRecommendationHsa'
  has_decision :four_confirm_hsa_initial_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmHsaInitialDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmHsaInitialDeclineDndStaff'
  has_decision :four_schedule_criminal_hearing_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin', notification_class_name: 'Notifications::Four::ScheduleCriminalHearingHousingSubsidyAdmin'
  has_decision :four_approve_match_housing_subsidy_admin, decision_class_name: 'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin', notification_class_name: 'Notifications::Four::CriminalHearingScheduledClient'
  has_decision :four_confirm_housing_subsidy_admin_decline_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmHousingSubsidyAdminDeclineDndStaff', notification_class_name: 'Notifications::Four::ConfirmHousingSubsidyAdminDeclineDndStaff'
  has_decision :four_record_client_housed_date_housing_subsidy_administrator, decision_class_name: 'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator', notification_class_name: 'Notifications::Four::HousingSubsidyAdminDecisionClient'
  has_decision :four_confirm_match_success_dnd_staff, decision_class_name: 'MatchDecisions::Four::ConfirmMatchSuccessDndStaff', notification_class_name: 'Notifications::Four::ConfirmMatchSuccessDndStaff'

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
    active.where(arel_table[:stall_date].lteq(Date.current))
  end
  scope :stalled_notifications_unsent, -> do
    stalled.where(stall_contacts_notified: nil)
  end
  scope :stalled_notifications_sent, -> do
    stalled.where.not(stall_contacts_notified: nil)
  end
  scope :stalled_dnd_notifications_unsent, -> do
    dnd_interval = Config.get(:dnd_interval).days
    stalled_notifications_sent.
      where(arel_table[:stall_contacts_notified].lteq(dnd_interval.ago)).
      where(dnd_notified: nil)
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

  has_many :do_contacts,
    -> { where client_opportunity_match_contacts: {do: true} },
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

  has_many :decision_actions,
    class_name: 'MatchEvents::DecisionAction',
    foreign_key: :match_id

  # Preserved so that history of old mechanism works
  has_many :status_updates,
    class_name: 'MatchProgressUpdates::Base',
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
    return none unless user
    # admins & DND see everything
    return all if user.can_view_all_matches?
    # Allow logged-in users to see any match they are a contact on, and the ones they are granted via program visibility
    contact = user.contact
    contact_subquery = ClientOpportunityMatchContact
      .where(contact_id: contact.id)
      .pluck(:match_id)
    visible_subquery = visible_by(user).pluck(:id)
    where(id: contact_subquery + visible_subquery)
  end

  def accessible_by? user
    self.class.accessible_by_user(user).where(id: id).exists?
  end

  def show_client_info_to? contact
    return false unless contact
    return true if contact.user_can_view_all_clients?
    return past_first_step_or_all_steps_visible? if contact.in?(shelter_agency_contacts)
    return past_first_step_or_all_steps_visible? if contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa && client&.has_full_housing_release?
    return past_first_step_or_all_steps_visible? if (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && client_info_approved_for_release?

    client.accessible_by_user?(contact.user)
  end

  # Get visibility from the associated Program
  delegate :visible_by?, to: :program
  delegate :editable_by?, to: :program

  scope :visible_by, ->(user) {
    joins(:program).merge(Program.visible_by(user))
  }
  scope :editable_by, ->(user) {
    joins(:program).merge(Program.editable_by(user))
  }

  def past_first_step_or_all_steps_visible?
    return true if current_decision.blank?
    if match_route.class.name.in?([ 'MatchRoutes::Default' ])
      current_decision != self.send(match_route.initial_decision)
    else
      true
    end
  end

  def client_info_approved_for_release?
    if match_route.class.name.in?([ 'MatchRoutes::Default' ])
      return shelter_agency_approval_or_dnd_override? && client&.has_full_housing_release?
    else
      client&.has_full_housing_release? || false
    end
  end

  def can_see_match_yet? contact
    return false unless contact
    return true if contact.user_can_view_all_clients?
    return true if contact.in?(shelter_agency_contacts)

    return true if contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa
    return true if  (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && (shelter_agency_approval_or_dnd_override?)

    false
  end

  def client_name_for_contact contact, hidden:
    return '' unless client.present?

    if show_client_info_to?(contact)
      hide_name(name: client.full_name, hidden: hidden)
    else
      if client&.project_client&.non_hmis_client_identifier.blank?
        "(name withheld — #{id})"
      else
        hide_name(name: client&.project_client&.non_hmis_client_identifier, hidden: hidden)
      end
    end
  end

  def hide_name name:, hidden:
    hidden ? '(name hidden)' : name
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
    ).text_search(text).arel.exists

    opp_matches = Opportunity.where(
      Opportunity.arel_table[:id].eq arel_table[:opportunity_id]
    ).text_search(text).arel.exists


    contact_matches = ClientOpportunityMatchContact.where(
      ClientOpportunityMatchContact.arel_table[:match_id].eq(arel_table[:id])
    ).text_search(text).arel.exists

    where(
      Arel.sql(
        client_matches.
        or(opp_matches).
        or(contact_matches).
        or(arel_table[:id].eq(text)).to_sql
      )
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
    return nil if closed?
    # FIXME, should look for next decision on route based on route #match_steps
    @current_decision ||= initialized_decisions.order(id: :desc).limit(1).first
  end

  def declined_decision
    @declined_decision ||= initialized_decisions.where.not(decline_reason_id: nil)&.first
    @declined_decision ||= initialized_decisions.where(status: :declined)&.last
    @declined_decision
  end

  def clear_current_decision_cache!
    @current_decision = nil
  end

  def add_default_contacts!
    add_default_dnd_staff_contacts!
    add_default_housing_subsidy_admin_contacts!
    add_default_client_contacts!
    add_default_shelter_agency_contacts!
    add_default_ssp_contacts!
    add_default_hsp_contacts!
    add_default_do_contacts!
  end

  def contact_titles
    if match_route.show_default_contact_types
      default_contact_titles
    else
      current_contact_titles
    end
  end

  def current_contact_titles
    contacts_with_info = {}
    match_contacts.input_names.each do |input_name|
      if match_contacts.send(input_name).count > 0
        contacts_with_info[input_name] = match_contacts.label_for input_name
      end
    end
    contacts_with_info
  end

  def self.default_contact_titles
    {
      shelter_agency_contacts: "#{_('Shelter Agency')} Contacts",
      housing_subsidy_admin_contacts: "#{_('Housing Subsidy Administrators')}",
      ssp_contacts: "#{_('Stabilization Service Providers')}",
      hsp_contacts: "#{_('Housing Search Providers')}",
    }
  end

  def default_contact_titles
    self.class.default_contact_titles
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


  def expire_all_notifications(on: 1.week.from_now.to_date)
    notifications.update_all(expires_at: on)
  end

  def reset_and_destroy!
    self.class.transaction do
     client.make_available_in(match_route: match_route)
      update(active: false)
      opportunity.update! available_candidate: !opportunity.active_matches.exists?
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      expire_all_notifications
      destroy
   end
    Matching::RunEngineJob.perform_later
  end

  def would_be_client_multiple_match
    client_related_matches.on_route(match_route).active.exists? && match_route.should_prevent_multiple_matches_per_client
  end

  def would_be_opportunity_multiple_match
    opportunity.active_matches.exists? && !match_route.allow_multiple_active_matches
  end

  def can_be_reopened?
    return false if active?
    return false if would_be_client_multiple_match
    return false if would_be_opportunity_multiple_match

    true
  end

  def describe_closed_state
    restrictions = []
    restrictions << 'the client already has an active match on this route' if would_be_client_multiple_match
    restrictions << 'there is already another active match on&nbsp;' +
      link_to('this opportunity.', opportunity_matches_path(opportunity)) if would_be_opportunity_multiple_match

    html = 'This match is not active'
    if restrictions.present?
      html += ', and cannot be re-opened because ' + restrictions.join(', and ')
    else
      html += '.'
    end
    html.html_safe
  end

  def reopen!(contact)
    self.class.transaction do
      client.make_unavailable_in(match_route: match_route, expires_at: nil)
      update(closed: false, active: true, closed_reason: nil)
      current_decision.update(status: :pending)
      MatchEvents::Reopened.create(match_id: id, contact_id: contact.id)
    end
  end

  def activate!
    self.class.transaction do
      update! active: true
      client.make_unavailable_in(match_route: match_route, expires_at: nil) if match_route.should_prevent_multiple_matches_per_client
      opportunity.update available_candidate: false
      add_default_contacts!
      self.send(match_route.initial_decision).initialize_decision!
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      related_proposed_matches.destroy_all if ! match_route.should_activate_match
    end
  end

  def matched!
    self.class.transaction do
      opportunity.update available_candidate: false
      add_default_contacts!
      opportunity.notify_contacts_of_manual_match(self)
    end
  end

  def rejected!
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'rejected'
      client.make_available_in(match_route: match_route)
      opportunity.update! available_candidate: !opportunity.active_matches.exists?
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
      client.make_available_in(match_route: match_route)
      opportunity.update! available_candidate: !opportunity.active_matches.exists?
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
      client.make_available_in(match_route: match_route)
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

      # Cancel other matches on other routes
      if route.should_cancel_other_matches
        client_related_matches.each do |match|
          if match.current_decision.present?
            MatchEvents::DecisionAction.create(match_id: match.id,
                decision_id: match.current_decision.id,
                action: :canceled)
            reason = MatchDecisionReasons::AdministrativeCancel.find_by(name: 'Client received another housing opportunity')
            match.current_decision.update! status: 'canceled', administrative_cancel_reason_id: reason.id
            match.poached!
          else
            match.destroy
          end
        end
        client.update available: false
        # Prevent matching on any route
        client.make_unavailable_in_all_routes
      else
        # Prevent matching on this route again
        client.make_unavailable_in(match_route: route)
      end

      # Cleanup other matches on the same opportunity
      if route.should_activate_match && ! route.allow_multiple_active_matches
        # If the match was automatically activated, we just need to clean up any leftovers
        opportunity_related_matches.destroy_all
      else
        opportunity_related_matches.each do |match|
          if match.active
            MatchEvents::DecisionAction.create(match_id: match.id,
                decision_id: match.current_decision.id,
                action: :canceled)
            opportunity.notify_contacts_opportunity_taken(match)
            reason = MatchDecisionReasons::AdministrativeCancel.find_by(name: 'Vacancy filled by other client')
            match.current_decision.update! status: 'canceled', administrative_cancel_reason_id: reason.id
            match.poached!
          elsif ! match.closed?
            match.destroy
          end
        end
      end

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

  def cancel_opportunity_related_matches!
    opportunity_related_matches.active.each do |match|
      MatchEvents::DecisionAction.create(match_id: match.id,
        decision_id: match.current_decision.id,
        action: :canceled)
      opportunity.notify_contacts_opportunity_taken(match)
      reason = MatchDecisionReasons::AdministrativeCancel.find_by(name: 'Vacancy filled by other client')
      match.current_decision.update! status: 'canceled', administrative_cancel_reason_id: reason.id
      match.poached!
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

  def related_proposed_matches
    ClientOpportunityMatch.
      proposed.
      where(opportunity_id: opportunity_id)
  end

  def already_active_for_opportunity
    # This might be better to check for the sub-program...
    ClientOpportunityMatch.active.
      where(client_id: client_id, opportunity_id: opportunity_id).
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
      sub_program.dnd_staff_contacts.each do |contact|
        assign_match_role_to_contact :dnd_staff, contact
      end
      client.dnd_staff_contacts.each do |contact|
        assign_match_role_to_contact :dnd_staff, contact
      end
    end

    def add_default_housing_subsidy_admin_contacts!
      opportunity.housing_subsidy_admin_contacts.each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
      sub_program.housing_subsidy_admin_contacts.each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
      client.housing_subsidy_admin_contacts.each do |contact|
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
      sub_program.client_contacts.each do |contact|
        assign_match_role_to_contact :client, contact
      end
    end

    def add_default_shelter_agency_contacts!
      client.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
      sub_program.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
      if match_route.default_shelter_agency_contacts_from_project_client?
        client.project_client.shelter_agency_contacts.each do |contact|
          assign_match_role_to_contact :shelter_agency, contact
        end
      end
    end

    def add_default_ssp_contacts!
      sub_program.ssp_contacts.each do |contact|
        assign_match_role_to_contact :ssp, contact
      end
      client.ssp_contacts.each do |contact|
        assign_match_role_to_contact :ssp, contact
      end
    end

    def add_default_hsp_contacts!
      sub_program.hsp_contacts.each do |contact|
        assign_match_role_to_contact :hsp, contact
      end
      client.hsp_contacts.each do |contact|
        assign_match_role_to_contact :hsp, contact
      end
    end

    def add_default_do_contacts!
      sub_program.do_contacts.each do |contact|
        assign_match_role_to_contact :do, contact
      end
      client.do_contacts.each do |contact|
        assign_match_role_to_contact :do, contact
      end
    end

    def self.prioritized_by_client(match_route, scope)
      match_route.match_prioritization.prioritization_for_clients(scope)
    end

    def self.sort_options
      [
        {title: 'Oldest match', column: 'created_at', direction: 'asc'},
        {title: 'Most recent match', column: 'created_at', direction: 'desc'},
        # {title: 'Last name A-Z', column: 'last_name', direction: 'asc'},
        # {title: 'Last name Z-A', column: 'last_name', direction: 'desc'},
        # {title: 'First name A-Z', column: 'first_name', direction: 'asc'},
        # {title: 'First name Z-A', column: 'first_name', direction: 'desc'},
        {title: 'Recently changed', column: 'last_decision', direction: 'desc'},
        # {title: 'Longest standing client', column: 'calculated_first_homeless_night', direction: 'asc'},
        # {title: 'Most served', column: 'days_homeless', direction: 'desc'},
        # {title: 'Most served in last three years', column: 'days_homeless_in_last_three_years', direction: 'desc'},
        # {title: 'Current step', column: 'current_step', direction: 'desc'},
        {title: 'Initial Acceptance Expiration Date', column: 'shelter_expiration', direction: 'asc'},
        {title: 'VI-SPDAT Score', column: 'vispdat_score', direction: 'desc'},
        {title: 'Priority Score', column: 'vispdat_priority_score', direction: 'desc'},
      ]
    end

end
