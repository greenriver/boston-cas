module Decisions
  extend ActiveSupport::Concern

  included do
    def can_recreate_this_decision?
      can_reissue_notifications? || hsa_can_resend_this_step?
    end
    helper_method :can_recreate_this_decision?

    def hsa_can_resend_this_step?
      ["MatchDecisions::ProviderOnly::HsaAcceptsClient"].include?(@decision&.type) &&
      @match.contacts_editable_by_hsa && 
      current_contact.in?(@match.housing_subsidy_admin_contacts)
    end
  end
end