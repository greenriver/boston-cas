module MatchProgressUpdates
  class Base < ::ActiveRecord::Base
    self.table_name = 'match_progress_updates'
    has_paper_trail
    acts_as_paranoid

    belongs_to :match,
      class_name: 'ClientOpportunityMatch',
      inverse_of: :status_updates

    belongs_to :notification,
      class_name: 'Notifications::Base'
      
    belongs_to :contact,
      inverse_of: :status_updates
    delegate :name, to: :contact, prefix: true

    belongs_to :decision,
      class_name: MatchDecisions::Base.name,
      inverse_of: :status_updates

    scope :incomplete, -> do
      mpu_t = arel_table
      joins(:match).
      merge(ClientOpportunityMatch.active).
      where(response: nil).
      where(mpu_t[:due_at].lteq(Time.new))
    end

    scope :incomplete_for_contact, -> (contact:) do
      incomplete.
      where(contact_id: contact.id)
    end

    scope :should_notify_contact, -> do
      incomplete.
      where(requested_at: nil)
    end

    scope :should_notify_dnd, -> do
      mpu_t = arel_table
      incomplete.
      where.not(requested_at: nil).
      where(dnd_notified_at: nil).
      where(mpu_t[:notify_dnd_at].lteq(Time.new))
    end

    def name
      raise 'Abstract method'
    end

    def responses
      raise 'Abstract method'
    end

    def note_editable_by? editing_contact
      editing_contact &&
      contact == editing_contact 
    end

    def is_editable?
      response.blank? && Time.now >= due_at
    end

    def should_notify_dnd_of_lateness?
      is_editable? && dnd_notified_at.blank? && Time.now >= notify_dnd_at
    end

    def self.due_after
      1.month
    end

    def self.notify_dnd_if_no_response_by
      self.due_after + 1.week
    end

    def self.create_for_match! match
      match.public_send(self.match_contact_scope).each do |contact|  
        create!(
          match: match, 
          contact: contact,
          due_at: Time.now + self.due_after,
          notify_dnd_at: Time.now + self.notify_dnd_if_no_response_by
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

  end
end