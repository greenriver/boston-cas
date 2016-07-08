module MatchEvents
  class Base < ::ActiveRecord::Base
    # match events represent anything that happens in the lifecyle of a match
    # e.g.
    # match generation by the CAS
    # notifications being sent
    # actors accepting or declining the match
    
    self.table_name = 'match_events'

    has_paper_trail
    
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
      editing_contact &&
      contact == editing_contact # ||
      # editing_contact.user.try(:admin?)
    end
    
    def remove_note!
      self.note = nil
      save
    end

  end
end