###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module OpportunityDetails
  class Blank
    # Null Object that returns empty string, for use when there isn't a way to
    # get the information for whatever reason
    def initialize opportunity
      @opportunity = opportunity
    end
    
    def unit_name
      ''
    end
    
    def building_name
      ''
    end
    
    def program_name
      ''
    end

    def sub_program_name
      ''
    end
    
    def subgrantee_name
      ''
    end
    
    def organizations
      ''
    end

    def funding_source_name
      ''
    end

    def opportunity_for_archive
      {}
    end

    def services
      []
    end
    
    def rules_with_source
      []
    end
    
  end
end