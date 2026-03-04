###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

# Wraps a single timeline event or a group of NotificationDelivery events for display in match history.
# Provides a unified interface for the view and data attributes for Stimulus filtering/collapse.
class MatchHistoryDisplayEvent
  DEFAULT_DAYS = 90

  class << self
    def history_show_options
      [
        ['all', 'Show all'],
        [DEFAULT_DAYS.to_s, "Show events in last #{DEFAULT_DAYS} days"],
        ['custom', 'Custom Range'],
      ]
    end

    def history_default_show_value
      DEFAULT_DAYS.to_s
    end
  end

  attr_reader :event, :events, :grouped

  def initialize(event:, events: nil)
    @event = event
    @events = events || [event]
    @grouped = events.present? && events.size > 1
  end

  def timestamp
    @event.timestamp
  end

  def date
    timestamp.try(:to_date)
  end

  def name
    @event.name
  end

  def decision
    @event.decision
  end

  def step_name
    decision&.step_name || @event.try(:match)&.decision_active_at(timestamp)&.step_name
  end

  def contacts
    return [@event.contact].compact unless grouped

    @events.map(&:contact).compact.uniq
  end

  def contact_ids
    contacts.map(&:id).compact
  end

  def contact_names
    contacts.map(&:name).compact
  end

  def contact_display
    return @event.contact_name || 'Contact Missing' unless grouped
    return contacts.first&.name || 'Contact Missing' if contacts.size == 1

    "#{contacts.size} Contacts Notified"
  end

  def days_ago
    return nil unless date

    (Date.current - date).to_i
  end

  def history_row_metadata
    {
      history_target: 'row',
      history_date: date&.iso8601,
      history_event_type: name,
      history_contact_ids: contact_ids&.join(','),
      history_contact_names: contact_names&.join('|'),
      history_days_ago: days_ago,
    }
  end

  # Delegate to primary event for partial rendering (notes, etc.)
  def show_note?(current_contact)
    @event.respond_to?(:show_note?) && @event.show_note?(current_contact)
  end

  def note
    @event.respond_to?(:note) ? @event.note : nil
  end

  def note_editable_by?(editing_contact)
    @event.respond_to?(:note_editable_by?) && @event.note_editable_by?(editing_contact)
  end

  def client_last_seen
    @event.respond_to?(:client_last_seen) ? @event.client_last_seen : nil
  end

  def response
    @event.respond_to?(:response) ? @event.response : nil
  end

  def to_partial_path
    @event.is_a?(MatchProgressUpdates::Base) ? 'match_progress_updates/progress_update' : 'match_events/match_event'
  end
end
