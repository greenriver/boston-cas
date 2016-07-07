module OpportunityDetails
  class Base
    attr_reader :opportunity
    def initialize opportunity
      @opportunity = opportunity
    end
  end
end