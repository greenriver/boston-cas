###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
