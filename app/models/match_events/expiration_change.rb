module MatchEvents
  class ExpirationChange < Base
    validates :note, presence: true
    
    def name
      ''
    end
        
  end
end