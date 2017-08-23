module MatchEvents
  class ExpirationChange < Base
    validates :note, presence: true
    
    def name
      note
    end
        
  end
end