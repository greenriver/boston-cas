###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchProgressUpdates
  class Base < ::ApplicationRecord
    self.table_name = 'match_progress_updates'
    has_paper_trail
    acts_as_paranoid
    attr_accessor :working_with_client
    validates_presence_of :response, :client_last_seen, if: :submitting?
    validate :note_required_if_other!

    def to_partial_path
      'match_progress_updates/progress_update'
    end

    belongs_to :match, class_name: ClientOpportunityMatch.name, inverse_of: :status_updates

    belongs_to :notification, class_name: Notifications::Base.name

    belongs_to :contact, inverse_of: :status_updates
    delegate :name, to: :contact, allow_nil: true, prefix: true

    belongs_to :decision, class_name: MatchDecisions::Base.name

    has_one :match_route, through: :match
    delegate :stalled_interval, to: :match_route

    scope :incomplete, -> do
      joins(:match).
        merge(ClientOpportunityMatch.stalled).
        where(submitted_at: nil)
    end

    scope :incomplete_for_contact, ->(contact_id:) do
      incomplete.
        where.not(requested_at: nil).
        where(contact_id: contact_id)
    end

    scope :complete, -> do
      where.not(submitted_at: nil)
    end

    # any status updates that have been requested over DND interval ago (currently 1 week)
    scope :should_notify_dnd, -> do
      mpu_t = arel_table
      incomplete.
        where.not(requested_at: nil).
        where(mpu_t[:requested_at].lteq(dnd_interval.ago)).
        where(dnd_notified_at: nil)
    end

    alias_attribute :timestamp, :submitted_at

    def self.dnd_interval
      Config.get(:dnd_interval).days
    end

    def name
      raise 'Abstract method'
    end

    # def other_response
    #   'Other (note required)'
    # end

    # def still_active_responses
    #   [
    #     'Client searching for unit',
    #     'Client has submitted request for tenancy',
    #     'Client is waiting for project/sponsor based unit to become available',
    #     "#{Translation.translate('SSP')}/#{Translation.translate('HSP')}/#{Translation.translate('HSA')} waiting on documentation",
    #     "#{Translation.translate('SSP')}/#{Translation.translate('HSP')}/#{Translation.translate('HSA')}  CORI mitigation",
    #     'Client has submitted Reasonable Accommodation',
    #     other_response,
    #   ]
    # end

    # def no_longer_active_responses
    #   [
    #     'Client disappeared',
    #     'Client incarcerated',
    #     'Client in medical institution',
    #     'Client declining services',
    #     "#{Translation.translate('SSP')}/#{Translation.translate('HSP')}/#{Translation.translate('HSA')} unable to contact client",
    #     other_response,
    #   ]
    # end

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
      editing_contact.present? && (contact == editing_contact || match.can_create_administrative_note?(editing_contact))
    end

    def is_editable? # rubocop:disable Naming/PredicateName
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
      match.public_send(match_contact_scope).each do |contact|
        where(match_id: match.id, contact_id: contact.id).first_or_create!
      end
    end

    def self.match_contact_scope
      raise 'Abstract method'
    end

    def note_required_if_other!
      return unless response.present? && response_requires_note? && note.strip.blank?

      errors.add :note, 'must be filled in for some options'
    end

    def response_requires_note?
      (response.split(';').map(&:strip) & MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator.new.stalled_responses_requiring_note).any?
    end

    def self.contacts_for_stalled_matches
      contacts ||= begin
        contacts = {}
        ClientOpportunityMatch.joins(:client).stalled_notifications_unsent.each do |match|
          match.current_decision.stalled_decision_contacts.each do |contact|
            contacts[contact.id] ||= Set.new
            contacts[contact.id] << match.id
          end
        end
        contacts
      end
    end

    # Send one notification to each contact of a stalled match listing all stalled matches
    def self.send_notifications
      contacts = contacts_for_stalled_matches
      contacts.each do |contact_id, match_ids|
        notifications = []
        match_ids.each do |match_id|
          notifications << Notifications::ProgressUpdateRequested.create_for_match!(
            match_id: match_id,
            contact_id: contact_id,
          )
        end
        NotificationsMailer.progress_update_requested(notifications.map(&:id)).deliver_later
        notifications.each(&:record_delivery_event!)
      end
      # make note on all matches that a notification was sent
      match_ids = contacts.values.map(&:to_a).flatten.uniq
      ClientOpportunityMatch.where(id: match_ids).update_all(stall_contacts_notified: Time.current)
    end

    def self.dnd_contacts_for_late_stalled_matches
      contacts ||= begin
        contacts = {}
        ClientOpportunityMatch.joins(:client).stalled_dnd_notifications_unsent.each do |match|
          match.dnd_staff_contacts.each do |contact|
            contacts[contact.id] ||= Set.new
            contacts[contact.id] << match.id
          end
        end
        contacts
      end
    end

    # send one notification per dnd staff contact
    def self.batch_should_notify_dnd
      contacts = dnd_contacts_for_late_stalled_matches
      contacts.each do |contact_id, match_ids|
        notifications = []
        match_ids.each do |match_id|
          notifications << Notifications::DndProgressUpdateLate.create_for_match!(
            match_id: match_id,
            contact_id: contact_id,
          )
        end
        NotificationsMailer.dnd_progress_update_late(notifications.map(&:id)).deliver_later
        notifications.each(&:record_delivery_event!)
      end
      # make note on all matches that a notification was sent
      match_ids = contacts.values.map(&:to_a).flatten.uniq
      ClientOpportunityMatch.where(id: match_ids).update_all(dnd_notified: Time.current)
    end

    def include_in_tracking_sheet?
      true
    end

    def tracking_events
      event_note = []
      event_note << "Client last seen: #{client_last_seen}" if client_last_seen.present?
      event_note << response if response.present?
      event_note << "Note: #{note}" if note.present?

      [[created_at.to_date, event_note.join('; ')]]
    end

    def include_tracking_event?
      tracking_events.present?
    end

    def next_step_number(step_number)
      step_number # default to staying the same
    end
  end
end
