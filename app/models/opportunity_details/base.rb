module OpportunityDetails
  class Base
    include MatchArchive
    attr_reader :opportunity
    def initialize opportunity
      @opportunity = opportunity
    end
  end
end