###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchEvents
  class Base < ::ApplicationRecord
    # match events represent anything that happens in the lifecyle of a match
    # e.g.
    # match generation by the CAS
    # notifications being sent
    # actors accepting or declining the match

    self.table_name = 'match_events'

    has_paper_trail
    acts_as_paranoid
    def to_partial_path
      'match_events/match_event'
    end

    belongs_to :match, class_name: 'ClientOpportunityMatch', inverse_of: :events

    belongs_to :notification, class_name: 'Notifications::Base'
    belongs_to :decision, class_name: 'MatchDecisions::Base'
    belongs_to :contact, inverse_of: :events

    delegate :name, to: :contact, allow_nil: true, prefix: true

    belongs_to :not_working_with_client_reason, class_name: 'MatchDecisionReasons::Base'

    scope :canceled_other_clients, -> do
      where(action: :other_clients_canceled)
    end

    scope :declined_or_canceled, -> do
      where(action: ['declined', 'canceled'])
    end

    scope :between, ->(range) do
      where(created_at: range)
    end

    def name
      raise 'Abstract method'
    end

    def timestamp
      created_at
    end

    def date
      timestamp.to_date
    end

    def note_editable_by? editing_contact
      editing_contact.present? && (contact == editing_contact || match.can_create_administrative_note?(editing_contact))
    end

    def remove_note!
      self.note = nil
      save
    end

    def is_editable? # rubocop:disable Naming/PredicateName
      false
    end

    def show_note?(_current_contact)
      false
    end

    def include_in_tracking_sheet?
      false
    end

    def tracking_events
      []
    end

    def include_tracking_event?
      tracking_events.present?
    end

    def next_step_number(step_number)
      step_number # default to staying the same
    end
  end
end
