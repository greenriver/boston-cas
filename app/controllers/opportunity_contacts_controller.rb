###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class OpportunityContactsController < AssociatedContactsController

  private

    def contact_owner_source
      Opportunity
    end
    
    def contact_join_model_source
      @contact_owner.opportunity_contacts
    end
    
    def join_model_class
      OpportunityContact
    end

end