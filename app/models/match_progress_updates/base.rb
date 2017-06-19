module MatchProgressUpdates
  class Base < ::ActiveRecord::Base
    has_paper_trail
    acts_as_paranoid

    belongs_to :match,
      class_name: 'ClientOpportunityMatch',
      inverse_of: :events

    belongs_to :notification,
      class_name: 'Notifications::Base'
      
    belongs_to :contact,
      inverse_of: :events
    delegate :name, to: :contact, prefix: true

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
      false
    end

    def should_notify_dnd_of_lateness?
      response.blank? && dnd_notified_at.blank? && Time.now >= notify_dnd_at
    end

    def self.due_after
      1.month
    end

    def self.notify_dnd_if_no_response_by
      self.due_after + 1.week
    end
  end
end