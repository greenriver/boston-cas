###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module OpportunityDetails
  class Base
    include MatchArchive
    attr_reader :opportunity
    def initialize opportunity
      @opportunity = opportunity
    end
  end
end
