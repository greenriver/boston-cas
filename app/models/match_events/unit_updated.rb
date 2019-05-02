module MatchEvents
  class UnitUpdated < Base
    def name
      "Building and/or unit changed. #{note}"
    end
  end
end