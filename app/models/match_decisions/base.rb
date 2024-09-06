###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  class Base < ApplicationRecord
    extend OrderAsSpecified
    # MatchDecision objects represent individual decision points
    # in the flow map for a given match.  e.g. DND initial approval,
    # or shelter agency approval

    # Decisions provide callback functionality for taking action based on
    # the current status.  See #run_status_callback

    # Subclasses should define valid statuses in #statuses and
    # corresponding callbacks in a StatusCallbacks inner class

    self.table_name = 'match_decisions'

    has_paper_trail
    acts_as_paranoid

    belongs_to :match, class_name: 'ClientOpportunityMatch', inverse_of: :decisions
    belongs_to :contact
    has_one :program, through: :match
    has_one :match_route, through: :match

    # these need to be present on the base class for preloading
    # subclasses should include MatchDecisions::AcceptsDeclineReason
    # and/or MatchDecisions::AcceptsNotWorkingWithClientReason if they intend to use these
    belongs_to :decline_reason, class_name: 'MatchDecisionReasons::Base'
    belongs_to :not_working_with_client_reason, class_name: 'MatchDecisionReasons::Base'
    belongs_to :administrative_cancel_reason, class_name: 'MatchDecisionReasons::Base'

    # We collect notes on our forms, and pass them on to events where they are stored
    attr_accessor :note
    # We provide an option to park clients on the DND initial review
    attr_accessor :prevent_matching_until
    # We provide an option to expire the shelter agency initial review
    attr_accessor :shelter_expiration

    scope :pending, -> { where(status: [:pending, :other_clients_canceled]) }
    scope :initialized_decisions, -> do
      where.not(status: nil)
    end
    scope :awaiting_action, -> do
      where(status: [:pending, :other_clients_canceled, :acknowledged])
    end
    scope :last_updated_before, ->(date) do
      where(arel_table[:updated_at].lteq(date))
    end

    scope :canceled_other_clients, -> do
      where(status: :other_clients_canceled)
    end

    has_many :decision_action_events,
             class_name: MatchEvents::DecisionAction.name,
             foreign_key: :decision_id

    validate :ensure_status_allowed, if: :status
    validate :cancellations, if: :administrative_cancel_reason_id

    ####################
    # Attributes
    ####################

    alias_attribute :timestamp, :updated_at

    def label
      # default behavior.  subclasses will probably want to override this
      decision_type.humanize.titleize
    end

    def step_tag
      nil
    end

    def contact_name
      contact&.full_name
    end
    alias actor_name contact_name

    def editable?
      # can this decision be updated by a notification response?
      # override this default behavior in subclasses
      initialized? && match_open? && saved_status !~ /\A(acknowledged|accepted|confirmed|declined|canceled|rejected|complete|completed|scheduled|no_hearing|mitigation_required|mitigation_not_required|decline_overridden|decline_overridden_returned|decline_confirmed)\z/
    end

    def expires?
      false
    end

    def default_shelter_expiration
      nil
    end

    def stallable?
      false
    end

    def skipped?
      false
    end

    def show_address_field?
      match_route.show_address_field
    end

    def show_referral_source?
      match_route.show_referral_source
    end

    def show_move_in_date?
      match_route.show_move_in_date
    end

    def started?
      status&.to_sym == :accepted
    end

    def stalled_after
      match_route.stalled_interval.days
    end

    def stalled_contact_types
      []
    end

    def date_successful
      return nil unless started?

      updated_at
    end

    def stalled_decision_contacts
      stalled_contact_types.map do |contact_method|
        match.public_send(contact_method)
      end.flatten.compact
    end

    def set_stall_date
      stall_on = (Date.current + stalled_after if stallable? && stalled_after.positive?)

      match.update(
        stall_date: stall_on,
        stall_contacts_notified: nil,
        dnd_notified: nil,
      )
    end

    def still_active_responses
      @still_active_responses ||= StalledResponse.active.ordered.
        engaging.
        for_decision(self.class.name).
        distinct.
        map(&:format_for_checkboxes)
    end

    def no_longer_active_responses
      @no_longer_active_responses ||= StalledResponse.active.ordered.
        not_engaging.for_decision(self.class.name).
        distinct.
        map(&:format_for_checkboxes)
    end

    def stalled_responses_requiring_note
      @stalled_responses_requiring_note ||= StalledResponse.active.
        requiring_note.
        distinct.
        pluck(:reason)
    end

    def to_param
      decision_type
    end

    def notifications(fetch_strategy: :single_decision) # rubocop:disable Lint/UnusedMethodArgument
      match.send("#{decision_type}_notifications")
    end

    def actor_type
      raise 'Abstract method'
    end

    def contact_actor_type
      raise 'Abstract method'
    end

    def step_name
      raise 'Not implemented'
    end

    def show_client_match_attributes?
      false
    end

    def include_additional_shelter_agency_decline?
      false
    end

    def declineable_by?(_contact)
      false
    end

    ######################
    # Decision Lifecycle
    ######################

    # This method is meant to be called when a decision becomes active
    # do things like set the initial "pending" status and
    # send notifications
    # All sub-class overrides should call this first
    def initialize_decision!(send_notifications: true) # rubocop:disable Lint/UnusedMethodArgument
      # always reset the stall date when the match moves into a new step
      set_stall_date
    end

    def uninitialize_decision!(send_notifications: false)
      update(status: nil)
      previous_step&.initialize_decision!(send_notifications: send_notifications)
    end

    def initialized?
      status.present?
    end

    def match_open?
      !match.closed?
    end

    # Sometimes the contacts change during a match and notifications should be re-issued
    # to everyone including the new contact (This runs the notification part of StatusCallbacks#accepted on
    # on the prior step)
    def recreate_notifications_for_this_step
      notifications_for_this_step.each do |n|
        n.create_for_match! match
      end
    end

    def notifications_for_this_step
      # override in subclass, return an array of notifications appropriate to resend for the current step
    end

    def holds_voucher?
      false
    end

    ######################
    # Status Handling
    ######################

    # override in subclass with a hash of {value: 'Label'}
    def statuses
      {}
    end

    # Overridden for decisions that can be overridden by DND and indicate
    # the status visually
    def status_label
      statuses[status && status.to_sym]
    end

    def run_status_callback!(**dependencies)
      match.clear_current_decision_cache!
      status_callbacks.new(self, dependencies).public_send(status)
    end

    # inherit in subclasses and add methods for each entry in #statuses
    class StatusCallbacks
      attr_reader :decision, :dependencies
      def initialize(decision, dependencies)
        @decision = decision
        @dependencies = dependencies
      end
      delegate :match, to: :decision

      private def user
        @dependencies.try(:[], :user)
      end

      def back
        @decision.uninitialize_decision!
      end
    end
    private_constant :StatusCallbacks

    def record_action_event! contact:
      decision_action_events.create! match: match, contact: contact, action: status, note: note
    end

    def record_updated_unit! unit_id:, contact_id:
      voucher = match.opportunity.voucher
      return unless unit_id.present? && voucher.unit.present?
      return unless voucher.unit_id != unit_id.to_i

      details = match.opportunity_details
      previous_unit = "#{details.unit_name} at #{details.building_name}"
      voucher.update!(skip_match_locking_validation: true, unit_id: unit_id)
      MatchEvents::UnitUpdated.create(match_id: match.id, note: "Previously: #{previous_unit}", contact_id: contact_id)
    end

    # override in subclass
    def notify_contact_of_action_taken_on_behalf_of contact:
    end

    def self.model_name
      @model_name ||= ActiveModel::Name.new(self, nil, 'decision')
    end

    def to_partial_path
      "match_decisions/#{decision_type}"
    end

    def permitted_params
      [:status, :note, :include_note_in_email, :prevent_matching_until, :administrative_cancel_reason_other_explanation, :disable_opportunity]
    end

    def whitelist_params_for_update params
      result = params.require(:decision).permit(permitted_params)
      # also allow one cancel reason
      reason_id_array = Array.wrap params.require(:decision)[:administrative_cancel_reason_id]
      cancel_reason_id = reason_id_array.select(&:present?).first
      result.merge! administrative_cancel_reason_id: cancel_reason_id
      result
    end

    # By default we allow admins access to any step, the following is what you'll
    # want 90% of the time for steps assigned to normal contacts
    ############
    # contact.user_can_act_on_behalf_of_match_contacts? ||
    #   contact.in?(match.send(contact_actor_type))
    ############
    # override in subclass
    def accessible_by?(contact)
      admin_only?(contact)
    end

    private def admin_only?(contact)
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def step_number
      match_route.class.match_steps[self.class.name]
    end

    def reporting_step_number
      match_route.class.match_steps_for_reporting[self.class.name]
    end

    def previous_step
      step_index = step_number
      step_list = if step_index
        match_route.class.match_steps
      else
        step_index = reporting_step_number
        match_route.class.match_steps_for_reporting
      end

      return nil if step_index == 1 # We are already at the first step

      step_index -= 1
      step_name = step_list.invert[step_index]
      step = match.decisions.find_by(type: step_name)
      step
    end

    def next_step
      next_step_name = match_route.class.match_steps.invert[step_number + 1]
      match.decisions.find_by(type: next_step_name)
    end

    def include_note?
      # Did the user indicate in the previous step that the included note text be included?
      previous_step&.include_note_in_email?
    end

    def step_note
      # Get the note from the most recent decision action in the previous step (in case there is more than one (e.g, if the match has been backed up)
      previous_step&.decision_action_events&.order(created_at: :desc)&.limit(1)&.pluck(:note)&.first
    end

    def send_notifications_for_step
      notifications_for_this_step.each do |notification|
        notification.create_for_match! match
      end
    end

    def inform_client(client_message)
      client = match.client
      return unless client.email.present? && client.send_emails?

      ClientMailer.send(client_message, match).deliver_later
      MatchEvents::ClientInformed.create!(match: match)
    end

    def self.closed_match_statuses
      [
        :declined,
        :canceled,
        :rejected,
        :shelter_declined,
      ]
    end

    def self.match_steps_for_reporting
      MatchRoutes::Base.match_steps_for_reporting
    end

    def self.available_sub_types_for_search
      MatchRoutes::Base.available_sub_types_for_search
    end

    def self.filter_options
      MatchRoutes::Base.filter_options
    end

    def self.stalled_match_filter_options
      MatchRoutes::Base.stalled_match_filter_options
    end

    def canceled_status_label
      if administrative_cancel_reason_other_explanation.present?
        "Match canceled administratively: #{administrative_cancel_reason&.name} (#{administrative_cancel_reason_other_explanation})"
      elsif administrative_cancel_reason.present?
        "Match canceled administratively: #{administrative_cancel_reason.name}"
      else
        'Match canceled administratively'
      end
    end

    def backup_status_label
      "Match administratively moved back one step to: #{previous_step.step_name}"
    end

    def incomplete_active_done?
      status_sym = status.try(:to_sym)
      return :canceled if self.class.closed_match_statuses.include?(status_sym)
      return :canceled if status_sym == :pending && match.closed?
      return :skipped if status_sym == :skipped
      return :active if editable?
      return :incomplete if status_sym == :pending || status_sym == :other_clients_canceled || status.blank?

      :done
    end

    private def decision_type
      self.class.to_s.demodulize.underscore
    end

    private def status_callbacks
      self.class.const_get :StatusCallbacks
    end

    def step_cancel_reasons
      [
        'Match expired',
        'Client has declined match',
        'Client has disengaged',
        'Client has disappeared',
        'SSP CORI',
        'HSP CORI',
        'Incarcerated',
        'Vacancy should not have been entered',
        'Client received another housing opportunity',
        'Client no longer eligible for match',
        'Client deceased',
        'Vacancy filled by other client',
        'Other',
      ]
    end

    def cancel_reasons
      MatchDecisionReasons::All.where(name: step_cancel_reasons)
    end

    private def ensure_status_allowed
      errors.add :status, 'is not allowed' if statuses.with_indifferent_access[status].blank?
    end

    private def cancellations
      errors.add :administrative_cancel_reason_other_explanation, "must be filled in if choosing 'Other'" if status == 'canceled' && administrative_cancel_reason&.other? && administrative_cancel_reason_other_explanation.blank?
    end

    private def notification_class
      "Notifications::#{self.class.to_s.demodulize}".constantize
    end

    private def saved_status
      changed_attributes[:status] || status
    end
  end
end
