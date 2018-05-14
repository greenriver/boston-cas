module MatchDecisions
  class Base < ActiveRecord::Base
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
    has_one :match_route, through: :program

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

    scope :pending, -> { where(status: :pending) }
    scope :awaiting_action, -> do
      where(status: [:pending, :acknowledged])
    end
    scope :last_updated_before, -> (date) do
      where(arel_table[:updated_at].lteq(date))
    end

    has_many :decision_action_events,
      class_name: MatchEvents::DecisionAction.name,
      foreign_key: :decision_id

    has_many :status_updates,
      class_name: MatchProgressUpdates::Base.name,
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

    def contact_name
      contact && contact.full_name
    end
    alias_method :actor_name, :contact_name

    def editable?
      # can notification responses update this decision?
      false
    end

    def to_param
      decision_type
    end

    def notifications fetch_strategy: :single_decision
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

    ######################
    # Decision Lifecycle
    ######################

    # This method is meant to be called when a decision becomes active
    # do things like set the initial "pending" status and
    # send notifications
    def initialize_decison! send_notifications: true
      # no-op override in subclass
    end

    def uninitialize_decision! send_notifications: false
      update(status: nil)
      if previous_step
        previous_step.initialize_decision!(send_notifications: send_notifications)
      end
    end

    def initialized?
      status.present?
    end

    def editable?
      # can this decision be updated by a notification response?
      # override this default behavior in subclasses
      initialized? && match_open?
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

    def run_status_callback! **dependencies
      status_callbacks.new(self, dependencies).public_send status
    end

    # inherit in subclasses and add methods for each entry in #statuses
    class StatusCallbacks
      attr_reader :decision, :dependencies
      def initialize decision, options
        @decision = decision
        @dependencies = dependencies
      end
      delegate :match, to: :decision

      def back
        @decision.uninitialize_decision!
      end
    end
    private_constant :StatusCallbacks


    def record_action_event! contact:
      decision_action_events.create! match: match, contact: contact, action: status, note: note
    end

    # override in subclass
    def notify_contact_of_action_taken_on_behalf_of contact:

    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, nil, "decision")
    end

    def to_partial_path
      "match_decisions/#{decision_type}"
    end

    def permitted_params
      [:status, :note, :prevent_matching_until, :administrative_cancel_reason_other_explanation]
    end

    def whitelist_params_for_update params
      result = params.require(:decision).permit(permitted_params)
      # also allow one cancel reason
      reason_id_array = Array.wrap params.require(:decision)[:administrative_cancel_reason_id]
      cancel_reason_id = reason_id_array.select(&:present?).first
      result.merge! administrative_cancel_reason_id: cancel_reason_id
      result
    end

    # override in subclass
    def accessible_by? contact
      false
    end

    def step_number
      match_route.class.match_steps[self.class.name]
    end

    def previous_step
      return unless step_number.present?
      previous_step_name = match_route.class.match_steps.invert[step_number - 1]
      match.decisions.find_by(type: previous_step_name)
    end

    def next_step
      next_step_name = match_route.class.match_steps.invert[step_number + 1]
      match.decisions.find_by(type: next_step_name)
    end

    def send_notifications_for_step
      notifications_for_this_step.each do |notification|
        notification.create_for_match! match
      end
    end

    def self.closed_match_statuses
      [
        :declined,
        :canceled,
        :rejected,
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
        "Match canceled administratively: #{administrative_cancel_reason.name} (#{administrative_cancel_reason_other_explanation})"
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
      return :canceled if self.class.closed_match_statuses.include?(status.try(:to_sym))
      return :active if editable?
      return :incomplete if status == :pending || status.blank?
      :done
    end

    private

      def decision_type
        self.class.to_s.demodulize.underscore
      end

      def status_callbacks
        self.class.const_get :StatusCallbacks
      end

      def ensure_status_allowed
        if statuses.with_indifferent_access[status].blank?
          errors.add :status, 'is not allowed'
        end
      end

      def cancellations
        if status == 'canceled' && administrative_cancel_reason&.other? && administrative_cancel_reason_other_explanation.blank?
          errors.add :administrative_cancel_reason_other_explanation, "must be filled in if choosing 'Other'"
        end
      end

      def notification_class
        "Notifications::#{self.class.to_s.demodulize}".constantize
      end

      def saved_status
        changed_attributes[:status] || status
      end

  end

end
