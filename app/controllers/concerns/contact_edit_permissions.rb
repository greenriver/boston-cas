module ContactEditPermissions
  extend ActiveSupport::Concern
  
  included do
    def hsa_can_edit_contacts?
      @match.contacts_editable_by_hsa && current_contact.in?(@match.housing_subsidy_admin_contacts)
    end
    helper_method :hsa_can_edit_contacts?

    def cant_edit_self?
      ! current_contact.user_can_edit_match_contacts? && hsa_can_edit_contacts?
    end
    helper_method :cant_edit_self?    
  end
  
end