###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientOpportunityMatch < ApplicationRecord
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include ClientOpportunityMatches::HasDecisions
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  self.table_name = 'client_opportunity_matches'
  def self.model_name
    @model_name ||= ActiveModel::Name.new(self, nil, 'match')
  end

  acts_as_paranoid
  has_paper_trail

  after_create :create_match_created_event!

  belongs_to :client
  belongs_to :opportunity
  belongs_to :match_route, class_name: 'MatchRoutes::Base'

  delegate :opportunity_details, to: :opportunity, allow_nil: true
  delegate :contacts_editable_by_hsa, to: :match_route
  delegate :has_buildings?, to: :sub_program
  has_one :sub_program, through: :opportunity, foreign_key: 'client_opportunity_match_id'
  has_one :program, through: :sub_program, foreign_key: 'client_opportunity_match_id'
  has_one :project_client, through: :client, foreign_key: 'client_opportunity_match_id'

  has_many :notifications, class_name: 'Notifications::Base', foreign_key: 'client_opportunity_match_id'

  has_many :match_mitigation_reasons, foreign_key: 'client_opportunity_match_id'
  has_many :mitigation_reasons, through: :match_mitigation_reasons, foreign_key: 'client_opportunity_match_id'

  # Default Match Route
  has_decision :match_recommendation_dnd_staff
  has_decision :match_recommendation_shelter_agency
  has_decision :confirm_shelter_agency_decline_dnd_staff
  has_decision :schedule_criminal_hearing_housing_subsidy_admin
  has_decision :confirm_shelter_decline_of_hearing
  has_decision :approve_match_housing_subsidy_admin
  has_decision :confirm_shelter_decline_of_hsa_approval
  has_decision :confirm_housing_subsidy_admin_decline_dnd_staff
  has_decision :record_client_housed_date_shelter_agency # Legacy decision type as of 10/16/2016
  has_decision :confirm_shelter_decline_of_housed
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
  include RouteFourDecisions

  # Match Route Five
  include RouteFiveDecisions

  # Match Route 6
  include RouteSixDecisions

  # Match Route 7
  include RouteSevenDecisions

  # Match Route 8
  include RouteEightDecisions

  # Match Route 9
  include RouteNineDecisions

  # Match Route 10
  include RouteTenDecisions

  # Match Route 11
  include RouteElevenDecisions

  # Match Route 12
  include RouteTwelveDecisions

  # Match Route 13
  include RouteThirteenDecisions

  has_many :referral_events, class_name: 'Warehouse::ReferralEvent', foreign_key: 'client_opportunity_match_id'
  has_one :active_referral_event, -> { where(referral_result: nil) }, class_name: 'Warehouse::ReferralEvent', foreign_key: 'client_opportunity_match_id'

  CLOSED_REASONS = ['success', 'rejected', 'canceled'].freeze
  validates :closed_reason, inclusion: { in: CLOSED_REASONS, if: :closed_reason }

  scope :on_route, ->(route) do
    joins(:program).merge(Program.on_route(route))
  end

  scope :diet, -> do
    select(attribute_names - ['universe_state'])
  end

  ###################
  ## Life cycle Scopes
  ###################

  scope :proposed, -> { where active: false, closed: false }
  scope :candidate, -> { proposed } # alias
  scope :active, -> { where active: true }
  scope :closed, -> { where closed: true }
  scope :open, -> { where closed: false }
  scope :successful, -> { where closed: true, closed_reason: 'success' }
  scope :success, -> { successful } # alias
  scope :unsuccessful, -> { where(closed: true).where.not(closed_reason: 'success') }
  scope :rejected, -> { where closed: true, closed_reason: 'rejected' }
  scope :preempted, -> { where closed: true, closed_reason: 'canceled' }
  scope :canceled, -> { preempted } # alias
  scope :expired, -> { where shelter_expiration: ..Date.current }
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
          md_t[:status].eq('decline_overridden').and(md_t[:type].eq('MatchDecisions::ConfirmShelterAgencyDeclineDndStaff')),
        ),
      )
  end
  scope :should_alert_warehouse, -> do
    success.joins(:match_route).merge(MatchRoutes::Base.should_cancel_other_matches)
  end

  scope :in_process_or_complete, -> do
    where(arel_table[:active].eq(true).or(arel_table[:closed].eq(true)))
  end

  scope :with_contact, ->(contact_id, contact_type) do
    contact_scope = ClientOpportunityMatchContact.all
    contact_scope = contact_scope.where(contact_id: contact_id) if contact_id.present?
    contact_scope = contact_scope.where(contact_type => true) if contact_type.present?
    joins(:contacts).merge(contact_scope)
  end

  ######################
  # Contact Associations
  ######################

  # All Contacts
  has_many :client_opportunity_match_contacts, dependent: :destroy, inverse_of: :match, foreign_key: 'match_id'
  has_many :contacts, through: :client_opportunity_match_contacts, foreign_key: 'client_opportunity_match_id'

  # filtered by role
  has_many :dnd_staff_contacts,
           -> { where(client_opportunity_match_contacts: { dnd_staff: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :housing_subsidy_admin_contacts,
           -> { where(client_opportunity_match_contacts: { housing_subsidy_admin: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :client_contacts,
           -> { where(client_opportunity_match_contacts: { client: true }) }, # remove active_contact to not limit client contacts to active users
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :shelter_agency_contacts,
           -> { where(client_opportunity_match_contacts: { shelter_agency: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :ssp_contacts,
           -> { where(client_opportunity_match_contacts: { ssp: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :hsp_contacts,
           -> { where(client_opportunity_match_contacts: { hsp: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :do_contacts,
           -> { where(client_opportunity_match_contacts: { do: true }) },
           foreign_key: 'client_opportunity_match_id',
           class_name: 'Contact',
           through: :client_opportunity_match_contacts,
           source: :contact

  has_many :hsa_or_shelter_agency_contacts, -> do
    where(client_opportunity_match_contacts: { housing_subsidy_admin: true }).
      or(where(client_opportunity_match_contacts: { shelter_agency: true }))
  end, class_name: 'Contact', through: :client_opportunity_match_contacts, source: :contact, foreign_key: 'client_opportunity_match_id'

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

  def includes_contact?(contact_type, contact_id)
    return send(contact_type).where(id: contact_id).present? if contact_type.present? && contact_id.present?
    return send(contact_type).present? if contact_type.present?
    return contacts.where(id: contact_id).present? if contact_id.present?

    true
  end

  def self.closed_filter_options
    {
      'Success' => 'success',
      'Rejected/Declined' => 'rejected',
      'Canceled/Pre-Empted' => 'canceled',
    }
  end

  delegate(:show_client_match_attributes?, to: :current_decision, allow_nil: true)

  def confidential?
    program&.confidential? ||
    client&.confidential? ||
    sub_program&.confidential? ||
    (
      !client&.has_full_housing_release?(match_route) &&
      Config.get(:limit_client_names_on_matches)
    )
  end

  def self.accessible_by_user(user)
    return none unless user
    # admins & DND see everything
    return all if user.can_view_all_matches?

    # Allow logged-in users to see any match they are a contact on, and the ones they are granted via program visibility
    where(id: accessible_match_ids(user))
  end

  def self.accessible_match_ids(user)
    Rails.cache.fetch([__method__, user], expires_in: 3.minutes) do
      contact = user.contact
      contact_subquery = ClientOpportunityMatchContact.
        where(contact_id: contact.id).
        pluck(:match_id)
      visible_subquery = visible_by(user).pluck(:id)
      (contact_subquery + visible_subquery).to_set
    end
  end

  def accessible_by? user
    @accessible_by ||= self.class.accessible_match_ids(user).include?(id)
  end

  def show_client_info_to? contact
    return false unless contact
    return true if contact.user_can_view_all_clients?
    return on_or_after_first_client_step? if contact.in?(shelter_agency_contacts)
    return on_or_after_first_client_step? if contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa && client&.has_full_housing_release?(match_route)
    return on_or_after_first_client_step? if (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && client_info_approved_for_release?

    client&.accessible_by_user?(contact.user)
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

  def on_or_after_first_client_step?
    return true if current_decision.blank?

    match_route.on_or_after_first_client_step?(current_decision)
  end

  def after_first_client_step?
    return true if current_decision.blank?

    match_route.after_first_client_step?(current_decision)
  end

  # Preload initialized_decisions
  def first_client_decision
    decision = initialized_decisions.detect do |d|
      d.class.name == match_route.first_client_step # rubocop:disable Style/ClassEqualityComparison
    end
    return nil unless decision&.started?

    decision
  end

  def client_info_approved_for_release?
    if match_route.class.name.in?(['MatchRoutes::Default'])
      shelter_agency_approval_or_dnd_override? && client&.has_full_housing_release?(match_route)
    else
      client&.has_full_housing_release?(match_route) || ! Config.get(:limit_client_names_on_matches)
    end
  end

  def can_see_match_yet? contact
    return false unless contact
    return true if contact.user_can_view_all_clients?
    return true if contact.in?(shelter_agency_contacts)

    return true if contact.in?(housing_subsidy_admin_contacts) && contacts_editable_by_hsa
    return true if (contact.in?(housing_subsidy_admin_contacts) || contact.in?(ssp_contacts) || contact.in?(hsp_contacts)) && shelter_agency_approval_or_dnd_override?

    false
  end

  def client_name_for_contact contact, hidden:
    return '' unless client.present?

    if show_client_info_to?(contact)
      hide_name(name: client.full_name, hidden: hidden)
    elsif client&.project_client&.non_hmis_client_identifier.blank?
      "(name withheld — #{id})"
    else
      hide_name(name: client&.project_client&.non_hmis_client_identifier, hidden: hidden)
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

    client_matches = Client.where(Client.arel_table[:id].eq arel_table[:client_id]).text_search(text).arel.exists

    opp_matches = Opportunity.where(Opportunity.arel_table[:id].eq arel_table[:opportunity_id]).text_search(text).arel.exists

    contact_matches = ClientOpportunityMatchContact.where(
      ClientOpportunityMatchContact.arel_table[:match_id].eq(arel_table[:id]),
    ).text_search(text).arel.exists

    where(
      Arel.sql(
        client_matches.
        or(opp_matches).
        or(contact_matches).
        or(arel_table[:id].eq(text)).to_sql,
      ),
    )
  end

  def self.send_summary_emails
    config = Config.last
    return if config.never_send_match_summary_email?
    return unless config.send_match_summary_email_on == Date.current.wday

    match_groups = [
      # stalled
      stalled,
      # canceled
      canceled.where(updated_at: 1.week.ago..),
      # expiring
      where(shelter_expiration: Date.current..Date.current + 1.week),
      # expired
      expired.where(shelter_expiration: 1.week.ago..),
      # active
      active,
    ]

    contact_ids = match_groups.map do |group|
      group.preload(:contacts).flat_map { |d| d.contacts.map(&:id) }
    end.flatten.uniq

    Contact.where(id: contact_ids).find_each do |contact|
      # If the contact is missing a user account, don't send this
      if contact.user.present? && contact.user.receive_weekly_match_summary_email?
        MatchDigestMailer.digest(contact).deliver_now
        # Attempt to be nice to the mailer
        sleep(5)
      end
    end
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

    later_decisions_first = match_route.class.match_steps_for_reporting.keys.reverse
    @current_decision ||= initialized_decisions.order_as_specified(type: later_decisions_first).find_by(status: [:pending, :acknowledged, :expiration_update])
    @current_decision ||= initialized_decisions.order_as_specified(type: later_decisions_first).limit(1).first
  end

  def unsuccessful_decision
    return canceled_decision if canceled?

    declined_decision
  end

  def unsuccessful_reason
    return unsuccessful_decision&.administrative_cancel_reason if canceled?

    unsuccessful_decision&.decline_reason
  end

  # Find the latest decision in the route that was declined with a reason
  # If that doesn't exist, pull the latest initialized decision that was declined
  def declined_decision
    decision_order = match_route.class.match_steps_for_reporting.keys
    @declined_decision ||= initialized_decisions.order_as_specified(type: decision_order).where.not(decline_reason_id: nil)&.last
    @declined_decision ||= initialized_decisions.order_as_specified(type: decision_order).where(status: :declined)&.last
    @declined_decision
  end

  # Find the latest decision in the route that was canceled with a reason
  # If that doesn't exist, pull the latest initialized decision that was canceled
  def canceled_decision
    return nil unless canceled?

    decision_order = match_route.class.match_steps_for_reporting.keys
    @canceled_decision ||= initialized_decisions.order_as_specified(type: decision_order).where.not(administrative_cancel_reason_id: nil)&.last
    @canceled_decision ||= initialized_decisions.order_as_specified(type: decision_order).where(status: :canceled)&.last
    @canceled_decision
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
    if match_route&.show_default_contact_types
      default_contact_titles
    else
      current_contact_titles
    end
  end

  def current_contact_titles
    contacts_with_info = {}
    match_contacts.input_names.each do |input_name|
      contacts_with_info[input_name] = match_route&.contact_label_for(input_name) if match_contacts.send(input_name).count.positive?
    end
    contacts_with_info
  end

  def default_contact_titles
    {
      shelter_agency_contacts: "#{match_route.contact_label_for(:shelter_agency_contacts)} Contacts",
      housing_subsidy_admin_contacts: match_route.contact_label_for(:housing_subsidy_admin_contacts).pluralize,
      ssp_contacts: match_route.contact_label_for(:ssp_contacts).pluralize,
      hsp_contacts: match_route.contact_label_for(:hsp_contacts).pluralize,
    }
  end

  def grouped_contact_list
    # We are trying to create a data shape this:
    # {
    #   'Group 1': {
    #     1 => 'First',
    #     2 => 'Second',
    #   },
    # }
    current_contact_titles.map do |input, title|
      [
        title,
        match_contacts.send(input).map do |contact|
          [
            contact.id,
            "#{contact.first_name} #{contact.last_name} | #{contact.email}",
          ]
        end.to_h,
      ]
    end.to_h
  end

  def overall_status
    if active?
      if status_declined?
        { name: 'Declined', type: 'danger' }
      else
        { name: 'In Progress', type: 'success' }
      end

    elsif closed?
      case closed_reason
      when 'success' then { name: 'Success', type: 'success' }
      when 'rejected' then { name: 'Rejected', type: 'danger' }
      when 'canceled' then { name: 'Pre-empted', type: 'danger' }
      end
    else
      { name: 'New', type: 'success' }

    end
  end

  def status_declined?
    match_route.status_declined?(self)
  end

  def stalled?
    self.class.stalled.where(id: id).exists?
  end

  def decision_stalled?
    return false unless initialized_decisions.pending&.first&.stallable?
    return false unless stall_date.present?

    stall_date <= Date.current
  end

  def canceled?
    closed? && closed_reason == 'canceled'
  end

  def canceled_recently?
    canceled? && updated_at > 1.week.ago
  end

  def expiring_soon?
    return false if shelter_expiration.blank?

    shelter_expiration > Date.current && shelter_expiration < Date.current + 1.week
  end

  def expired?
    return false if shelter_expiration.blank?

    shelter_expiration <= Date.current
  end

  def expired_recently?
    expired? && shelter_expiration > 1.week.ago
  end

  def successful?
    closed? && closed_reason == 'success'
  end

  def success_time
    send(match_route.success_decision).updated_at
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
    return false if stalled? && contact.in?(public_send(current_decision.contact_actor_type))

    can_create_administrative_note?(contact) || contact&.user&.can_create_overall_note?
  end

  def can_create_administrative_note? contact
    contact.present? && (contact.user.present? && (contact.user.can_approve_matches? || contact.user.can_reject_matches?))
  end

  def match_contacts
    @match_contacts ||= MatchContacts.new match: self
  end

  def expire_all_notifications(on: 1.week.from_now.to_date) # rubocop:disable Naming/MethodParameterName
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

  def top_priority?
    return false if closed?
    return false unless on_or_after_first_client_step?
    return false unless opportunity.multiple_active_matches?

    self == opportunity.prioritized_active_matches.first
  end

  def would_be_client_multiple_match
    client_related_matches.on_route(match_route).active.exists? && match_route.should_prevent_multiple_matches_per_client
  end

  def would_be_opportunity_multiple_match
    opportunity.active_matches.exists? && !match_route.allow_multiple_active_matches
  end

  def can_be_reopened?
    !(active || would_be_client_multiple_match || would_be_opportunity_multiple_match)
  end

  def restrictions_on_reopening
    restrictions = []
    restrictions << :client_multiple_match if would_be_client_multiple_match
    restrictions << :opportunity_multiple_match if would_be_opportunity_multiple_match
    restrictions
  end

  def reopen!(contact, user: nil)
    self.class.transaction do
      # Park client on any other routes where this route is set to block matching when the client is involved in this route
      match_route.routes_parked_on_active_match.reject(&:empty?).each do |park_route|
        client.make_unavailable_in(match_route: park_route.constantize, user: user, match: self, reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT)
      end
      update(closed: false, active: true, closed_reason: nil)
      current_decision.update(status: :pending)
      MatchEvents::Reopened.create(match_id: id, contact_id: contact.id)
      # If this match was picked up in nightly processing, the client now appears as housed in the warehouse,
      # so clean that up...
      Warehouse::CasHoused.where(match_id: id).destroy_all

      active_referral_event&.clear if Warehouse::Base.enabled?
    end
  end

  def activate!(touch_referral_event: true, user: nil)
    self.class.transaction do
      update!(active: true)
      # Park client on any other routes where this route is set to block matching when the client is involved in this route
      match_route.routes_parked_on_active_match.reject(&:empty?).each do |park_route|
        client.make_unavailable_in(match_route: park_route.constantize, user: user, match: self, reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT)
      end
      opportunity.update(available_candidate: false)
      add_default_contacts!
      requirements_with_inherited.each { |req| req.apply_to_match(self) }
      send(match_route.initial_decision).initialize_decision!
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      related_proposed_matches.destroy_all unless match_route.should_activate_match

      init_referral_event if Warehouse::Base.enabled? && touch_referral_event
    end
  end

  def matched!
    self.class.transaction do
      opportunity.update available_candidate: false
      add_default_contacts!
      opportunity.notify_contacts_of_manual_match(self)
    end
  end

  def rejected!(touch_referral_event: true)
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'rejected'
      unpark_routes_parked_for_active_match
      opportunity.update! available_candidate: !opportunity.active_matches.exists?
      RejectedMatch.create! client_id: client.id, opportunity_id: opportunity.id
      Matching::RunEngineJob.perform_later
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications

      active_referral_event&.rejected if Warehouse::Base.enabled? && touch_referral_event
    end
  end

  def canceled!(touch_referral_event: true)
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'canceled'
      unpark_routes_parked_for_active_match
      opportunity.update! available_candidate: !opportunity.active_matches.exists?
      RejectedMatch.create! client_id: client.id, opportunity_id: opportunity.id
      Matching::RunEngineJob.perform_later
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications

      active_referral_event&.rejected if Warehouse::Base.enabled? && touch_referral_event
    end
  end

  # Similar to a cancel, but allow the client to re-match the same opportunity
  # if it comes up again.  Also, don't re-run the matching engine, we'll
  # put the opportunity
  def poached!(touch_referral_event: true)
    self.class.transaction do
      update! active: false, closed: true, closed_reason: 'canceled'
      unpark_routes_parked_for_active_match
      opportunity.update! available_candidate: false
      opportunity.try(:voucher).try(:sub_program).try(:update_summary!)
      # Prevent access to this match by notification after 1 week
      expire_all_notifications

      active_referral_event&.rejected if Warehouse::Base.enabled? && touch_referral_event
    end
  end

  def succeeded!(touch_referral_event: true, user: nil)
    self.class.transaction do
      route = opportunity.match_route
      update! active: false, closed: true, closed_reason: 'success'

      # Cancel other matches on other routes
      if route.should_cancel_other_matches
        client_related_matches.each do |match|
          if match.current_decision.present?
            MatchEvents::DecisionAction.create(
              match_id: match.id,
              decision_id: match.current_decision.id,
              action: :canceled,
            )
            reason = MatchDecisionReasons::AdministrativeCancel.find_by(name: 'Client received another housing opportunity')
            match.current_decision.update! status: 'canceled', administrative_cancel_reason_id: reason.id
            match.poached!
          else
            match.destroy
          end
        end
        client.update available: false
        # Prevent matching on any route
      end

      # Park client on any other routes where this route is set to block matching when the client is successful on this route
      match_route.routes_parked_on_successful_match.reject(&:empty?).each do |park_route|
        client.make_unavailable_in(match_route: park_route.constantize, user: user, match: self, reason: UnavailableAsCandidateFor::SUCCESSFUL_MATCH_TEXT)
      end

      # Cleanup other matches on the same opportunity
      if route.should_activate_match && ! route.allow_multiple_active_matches
        # If the match was automatically activated, we just need to clean up any leftover ongoing matches
        opportunity_related_matches.open.destroy_all
      else
        opportunity_related_matches.each do |match|
          if match.active
            MatchEvents::DecisionAction.create(
              match_id: match.id,
              decision_id: match.current_decision.id,
              action: :canceled,
            )
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
      opportunity.unit&.update(available: false)
      if opportunity.voucher.present?
        opportunity.voucher.update available: false, skip_match_locking_validation: true
        opportunity.voucher.sub_program.update_summary!
      end
      # Prevent access to this match by notification after 1 week
      expire_all_notifications

      active_referral_event&.accepted if Warehouse::Base.enabled? && touch_referral_event
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

  def init_referral_event(event: sub_program&.event)
    return unless Warehouse::Base.enabled?
    # Don't create a new event if we have an incomplete one
    # But allow more than one event per match
    return active_referral_event if active_referral_event.present? && active_referral_event.referral_result.blank?
    return unless project_client&.from_hmis?

    # If the match is closed, see if we have any referral events with results, return the last one if we do
    latest_complete_referral_event = referral_events.where.not(referral_result: nil).last
    return latest_complete_referral_event if closed? && latest_complete_referral_event.present?

    # Otherwise the match is ongoing or closed and missing a result,
    # result will be added in ReferralEvent.sync_match_referrals!
    create_active_referral_event(
      cas_client_id: client.id,
      hmis_client_id: project_client.id_in_data_source,
      program_id: program.id,
      referral_date: match_created_event&.date,
      event: event,
    )
  end

  def assign_match_role_to_contact role, contact
    return unless contact.user&.active?

    join_model = client_opportunity_match_contacts.detect do |match_contact|
      match_contact.contact_id == contact.id
    end
    join_model ||= client_opportunity_match_contacts.build contact: contact
    join_model.send("#{role}=", true)
    join_model.save
  end

  private def add_default_dnd_staff_contacts!
    Contact.where(user_id: User.dnd_initial_contact.select(:id)).preload(:user).each do |contact|
      assign_match_role_to_contact :dnd_staff, contact
    end
    sub_program.dnd_staff_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :dnd_staff, contact
    end
    client.dnd_staff_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :dnd_staff, contact
    end
  end

  private def add_default_housing_subsidy_admin_contacts!
    opportunity.housing_subsidy_admin_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :housing_subsidy_admin, contact
    end
    sub_program.housing_subsidy_admin_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :housing_subsidy_admin, contact
    end
    client.housing_subsidy_admin_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :housing_subsidy_admin, contact
    end
    # If for some reason we forgot to setup the default HSA contacts
    # put the people who usually receive initial notifications in that role
    if contacts_editable_by_hsa && housing_subsidy_admin_contacts.blank? # rubocop:disable Style/GuardClause
      Contact.where(user_id: User.dnd_initial_contact.select(:id)).each do |contact|
        assign_match_role_to_contact :housing_subsidy_admin, contact
      end
    end
  end

  private def add_default_client_contacts!
    client.regular_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :client, contact
    end
    sub_program.client_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :client, contact
    end
  end

  private def add_default_shelter_agency_contacts!
    client.shelter_agency_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :shelter_agency, contact
    end
    sub_program.shelter_agency_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :shelter_agency, contact
    end
    if match_route.default_shelter_agency_contacts_from_project_client? # rubocop:disable Style/GuardClause
      client.project_client.shelter_agency_contacts.each do |contact|
        assign_match_role_to_contact :shelter_agency, contact
      end
    end
  end

  private def add_default_ssp_contacts!
    sub_program.ssp_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :ssp, contact
    end
    client.ssp_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :ssp, contact
    end
  end

  private def add_default_hsp_contacts!
    sub_program.hsp_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :hsp, contact
    end
    client.hsp_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :hsp, contact
    end
  end

  private def add_default_do_contacts!
    sub_program.do_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :do, contact
    end
    client.do_contacts.preload(:user).each do |contact|
      assign_match_role_to_contact :do, contact
    end
  end

  private def unpark_routes_parked_for_active_match
    # Get routes parked for the current client due to an active route
    parked_active_client_routes = client&.unavailable_as_candidate_fors&.map { |r| r.match_route_type if r.reason == UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT }&.compact
    # Get routes from the config that are to be parked due to an active match on the current route
    routes_to_park_by_active_match = match_route.routes_parked_on_active_match.reject(&:empty?)
    # Unpark routes where above lists intersect
    (parked_active_client_routes & routes_to_park_by_active_match).each do |parked_route|
      client&.make_available_in(match_route: parked_route.constantize)
    end
  end

  # List any matches that the client had at the same sub-program within the last year
  #
  # @return [Array] hashes of information about matches for this client
  #   that occurred at the same sub-program and closed within the last
  #   year. Format
  # [
  #   {
  #     id: match_id,
  #     terminal_step: 'Step Name',
  #     terminal_status: 'Label for step',
  #     terminal_date: timestamp_of_step,
  #    },
  # ]
  def similar_matches
    @similar_matches ||= client.client_opportunity_matches.closed.
      where.not(id: id).
      joins(:initialized_decisions, :sub_program).
      merge(SubProgram.where(id: sub_program.id)).
      to_a. # there's a JSON field, it really doesn't like to distinct on
      uniq.
      map do |m|
        decision = m.initialized_decisions.last
        {
          id: m.id,
          terminal_step: decision.step_name,
          terminal_status: decision.label,
          terminal_date: decision.updated_at,
        }
      end
  end

  def associated_file_tags
    tags = sub_program.file_tags.pluck(:tag_id).map { |tag| [tag, sub_program.name] } +
      requirements_with_inherited.map do |requirement|
        requirement.associated_file_tags.flatten.map do |tag|
          [
            tag,
            requirement.requirer.name,
          ]
        end
      end.flatten(1)
    tags.to_h
  end

  def self.prioritized_by_client(opportunity, scope)
    opportunity.active_prioritization_scheme.prioritization_for_clients(scope, opportunity: opportunity)
  end

  def self.sort_options
    [
      { title: 'Oldest match', column: 'created_at', direction: 'asc' },
      { title: 'Most recent match', column: 'created_at', direction: 'desc' },
      # {title: 'Last name A-Z', column: 'last_name', direction: 'asc'},
      # {title: 'Last name Z-A', column: 'last_name', direction: 'desc'},
      # {title: 'First name A-Z', column: 'first_name', direction: 'asc'},
      # {title: 'First name Z-A', column: 'first_name', direction: 'desc'},
      { title: 'Recently changed', column: 'last_decision', direction: 'desc' },
      # {title: 'Longest standing client', column: 'calculated_first_homeless_night', direction: 'asc'},
      # {title: 'Most served', column: 'days_homeless', direction: 'desc'},
      # {title: 'Most served in last three years', column: 'days_homeless_in_last_three_years', direction: 'desc'},
      # {title: 'Current step', column: 'current_step', direction: 'desc'},
      { title: 'Expiration Date', column: 'shelter_expiration', direction: 'asc' },
      { title: 'VI-SPDAT Score', column: 'vispdat_score', direction: 'desc' },
      { title: 'Priority Score', column: 'vispdat_priority_score', direction: 'desc' },
    ]
  end
end
