###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class Base < ::ActiveRecord::Base
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

    belongs_to :match,
      class_name: 'ClientOpportunityMatch',
      inverse_of: :events

    belongs_to :notification,
      class_name: 'Notifications::Base'

    belongs_to :decision,
      class_name: 'MatchDecisions::Base'

    belongs_to :contact,
      inverse_of: :events
    delegate :name, to: :contact, allow_nil: :true, prefix: true

    belongs_to :not_working_with_client_reason, class_name: 'MatchDecisionReasons::Base'

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

    def is_editable?
      false
    end

    def show_note?(current_contact)
      false
    end

  end
end