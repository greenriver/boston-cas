module MatchAccessContexts
  class AuthenticatedUser
    
    attr_reader :controller, :user
    
    def initialize controller
      @controller = controller
      @user = controller.current_user
    end
    
    def current_contact
      user.contact
    end
    
    def acknowledge_shelter_agency_notification?
      current_contact.in? controller.match.shelter_agency_contacts
    end
    
    def contacts_editable?
      user.dnd_staff? || user.admin?
    end
    
    def match_scope
      ClientOpportunityMatch.accessible_by_user user
    end
    
    def authenticate!
      controller.authenticate_user!
    end

    ################
    ### Path Helpers
    ################
  
    def match_path match, opts = {}
      controller.match_path match, opts
    end
    
    def match_decision_path match, decision, opts = {}
      controller.match_decision_path match, decision, opts
    end
    
    def match_decision_acknowledgment_path match, decision, opts = {}
      controller.match_decision_acknowledgment_path match, decision, opts
    end
    
    def edit_match_contacts_path match, opts = {}
      controller.edit_match_contacts_path match, opts
    end
    
    def match_contacts_path match, opts = {}
      controller.match_contacts_path match, opts
    end

    def match_client_details_path match, opts = {}
      controller.match_client_details_path match, opts
    end

  end
end