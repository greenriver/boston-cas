module MatchProgressUpdates
  class Base < ::ActiveRecord::Base
    self.table_name = 'match_progress_updates'
    has_paper_trail
    acts_as_paranoid
    attr_accessor :working_with_client
    validates_presence_of :response, :client_last_seen, if: :submitting?
    validate :note_required_if_other!

    DND_INTERVAL = if Rails.env.production?
      1.weeks
    else
      1.days
    end

    def to_partial_path
      'match_progress_updates/progress_update'
    end

    belongs_to :match,
      class_name: ClientOpportunityMatch.name,
      inverse_of: :status_updates

    belongs_to :notification,
      class_name: Notifications::Base.name
      
    belongs_to :contact,
      inverse_of: :status_updates
    delegate :name, to: :contact, prefix: true

    belongs_to :decision,
      class_name: MatchDecisions::Base.name,
      inverse_of: :status_updates

    scope :incomplete, -> do
      mpu_t = arel_table
      joins(:match).
      merge(ClientOpportunityMatch.stalled).
      where(submitted_at: nil)
      # where(mpu_t[:due_at].lteq(Time.new))
    end

    scope :incomplete_for_contact, -> (contact_id:) do
      incomplete.
      where(contact_id: contact_id)
    end

    scope :complete, -> do
      where.not(submitted_at: nil)
    end

    # any status updates where the match has been on the same decision
    # for a specified length of time (currently 1 month)
    # and we haven't already requested the update
    scope :should_notify_contact, -> do
      incomplete.
      where(requested_at: nil)
    end

    # any status updates that have been requested over DND interval ago (currently 1 week)
    scope :should_notify_dnd, -> do
      mpu_t = arel_table
      incomplete.
      where.not(requested_at: nil).
      where(mpu_t[:requested_at].lteq(DND_INTERVAL.ago)).
      where(dnd_notified_at: nil)
    end

    alias_attribute :timestamp, :submitted_at

    def name
      raise 'Abstract method'
    end

    def other_response
      'Other (note required)'
    end

    def still_active_responses
      [
        'Client searching for unit',
        'Client has submitted request for tenancy',
        'Client is waiting for project/sponsor based unit to become available',
        'SSP/HSA waiting on documentation',
        'SSP/HSA  CORI mitigation',
        other_response,
      ]
    end

    def no_longer_active_responses
      [
        'Client disappeared',
        'Client incarcerated',
        'Client in medical institution',
        'Client declining services',
        'SSP/HSA unable to contact client',
        other_response,
      ]
    end

    def submit!
      @submitting = true
      save!
    ensure
      @submitting = false
    end

    def submitting?
      @submitting
    end

    def note_editable_by? editing_contact
      editing_contact &&
      contact == editing_contact 
    end

    def is_editable?
      response.blank? && match.stalled?
    end

    def should_notify_dnd_of_lateness?
      is_editable? && dnd_notified_at.blank? && requested_at <= DND_INTERVAL.ago
    end

    def self.incomplete_for_contact?(contact_id:, match_id:)
      incomplete_for_contact(contact_id: contact_id).
        where(match_id: match_id).exists?
    end

    def self.create_for_match! match
      match.public_send(self.match_contact_scope).each do |contact|  
        create!(
          match: match, 
          contact: contact,
        )
      end
    end

    def self.send_notifications
      should_notify_contact.each do |progress_update|
        # Determine next notification number
        notification_number = self.where(
          contact_id: progress_update.contact_id,
          match_id: progress_update.match_id,
          requested_at: nil
        ).count
        decision_id = progress_update.match.current_decision.id
        requested_at = Time.now
        notification = Notifications::ProgressUpdateRequested.create_for_match!(
          progress_update.match, 
          contact: progress_update.contact
        )
        progress_update.update(
          notification_id: notification.id,
          notification_number: notification_number,
          decision_id: decision_id,
          requested_at: requested_at,
        )
      end
      should_notify_dnd.each do |dnd_notification|
        # Determine next notification number
        dnd_notified_at = Time.now
        Notifications::DndProgressUpdateLate.create_for_match!(
          dnd_notification.match
        )
        dnd_notification.update(
          dnd_notified_at: dnd_notified_at,
        )
      end
    end

    def self.match_contact_scope
      raise 'Abstract method'
    end

    def note_required_if_other!
      if response.include?(other_response) && note.strip.blank?
        errors.add :note, "must be filled in if choosing 'Other'"
      end
    end

  end
end