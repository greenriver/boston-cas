module MatchDecisions
  class MatchRecommendationDndStaff < Base
    
    include MatchDecisions::AcceptsDeclineReason

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_related_active_match
    # validate :note_present_if_status_declined
    validate :ensure_required_contacts_present_on_accept

    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting #{_('DND')} Review"
      when :accepted then "New Match Accepted by #{_('DND')}"
      when :declined then "New Match Declined by #{_('DND')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      end
    end
    
    def step_name
      "#{_('DND')} Initial Review"
    end

    def actor_type
      "#{_('DND')}"
    end

    def contact_actor_type
      nil
    end
    
    def statuses
      {
        pending: 'Pending', 
        accepted: 'Accept', 
        declined: 'Decline',
        canceled: 'Canceled',
      }
    end
    
    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def permitted_params
      super + [:prevent_matching_until, :shelter_expiration]
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::MatchRecommendationDndStaff.create_for_match! match
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def note_present_if_status_declined
      if note.blank? && status == 'declined'
        errors.add :note, 'Please note why the match is declined.'
      end
    end

    private def decline_reason_scope
      MatchDecisionReasons::DndStaffDecline.all
    end
    
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::MatchRecommendationDndStaff
      end
    end


    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        Notifications::MatchRecommendationClient.create_for_match!(match)
        match.match_recommendation_shelter_agency_decision.initialize_decision!
        # Setup recurring status notifications for SSP & Shelter Agency
        MatchProgressUpdates::Ssp.create_for_match!(match)
        MatchProgressUpdates::ShelterAgency.create_for_match!(match)
      end
      
      def declined
        match.rejected!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end
    

    def cant_accept_if_match_closed
      if save_will_accept? && match.closed
        then errors.add :status, "This match has already been closed."
      end
    end
    
    def cant_accept_if_related_active_match
      if save_will_accept? &&
        (match.client_related_matches.active.any? ||
          match.opportunity_related_matches.active.any?)
        then errors.add :status, "There is already another active match for this client or opportunity"          
      end
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      if save_will_accept? && match.shelter_agency_contacts.none?
        missing_contacts << "a #{_('Shelter Agency')} Contact"
      end

      if save_will_accept? && match.dnd_staff_contacts.none?
        missing_contacts << "a #{_('DND')} Staff Contact"
      end

      if save_will_accept? && match.housing_subsidy_admin_contacts.none?
        missing_contacts << "a #{_('Housing Subsidy Administrator')} Contact"
      end

      if missing_contacts.any?
        errors.add :match_contacts, "needs #{missing_contacts.to_sentence}"
      end
    end
 
  end

end

