module MatchProgressUpdates
  class Ssp < Base
    
    def name
      'Stabilization Service Provider status update'
    end

    def responses
      [
        'Response 1',
        'Response 2',
      ]
    end

    def note_editable_by? editing_contact
      editing_contact &&
      contact == editing_contact 
    end

    def is_editable?
      response.blank? && Time.now >= due_at
    end

    def self.due_after
      1.month
    end
  end
end