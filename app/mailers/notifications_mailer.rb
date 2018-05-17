class NotificationsMailer < DatabaseMailer

  private def setup_instance_variables notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
  end

  def match_recommendation_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation - Requires Your Action")
  end

  def match_recommendation_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Opportunity")
  end

  def match_recommendation_housing_subsidy_admin notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation")
  end

  def match_recommendation_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation")
  end

  def match_recommendation_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation")
  end

  def match_recommendation_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation - Requires Your Action")
  end

  def schedule_criminal_hearing_housing_subsidy_admin notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation - Requires Your Action")
  end

  def schedule_criminal_hearing_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation")
  end

  def schedule_criminal_hearing_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation")
  end
  
  def record_client_housed_date_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation Approved - Requires Your Action")
  end

  def record_client_housed_date_housing_subsidy_administrator notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation Approved - Requires Your Action")
  end

  def move_in_date_set notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation Move-in Date Set")
  end
  
  def confirm_match_success_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Housing Recommendation - Requires Final Approval")
  end
  
  def criminal_hearing_scheduled_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Hearing Scheduled")
  end

  def criminal_hearing_scheduled_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Hearing Scheduled")
  end

  def criminal_hearing_scheduled_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Hearing Scheduled")
  end
  
  def criminal_hearing_scheduled_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Hearing Scheduled")
  end
  
  def criminal_hearing_scheduled_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Hearing Scheduled")
  end
  
  def housing_subsidy_admin_decision_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end
  
  def housing_subsidy_admin_accepted_match_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Accepted by #{_('HSA')}")
  end
  
  def housing_subsidy_admin_declined_match_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('HSA')}")
  end

  def housing_subsidy_admin_declined_match_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('HSA')}")
  end

  def housing_subsidy_admin_declined_match_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('HSA')}")
  end

  def confirm_shelter_agency_decline_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('Shelter Agency')} - Requires Your Action")
  end

  def confirm_housing_subsidy_admin_decline_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('HSA')} - Requires Your Action")
  end

  def on_behalf_of notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Action taken on your behalf")
  end

  def no_longer_working_with_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Contact no longer working with Client")
  end

  def match_canceled notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Administratively Canceled")
  end

  def shelter_agency_accepted notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "#{_('Shelter Agency')} Accepted Match")
  end

  def shelter_agency_decline_accepted notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Decline Accepted")
  end
  # End Default Route

  # Provider Only
  def match_initiation_for_hsa notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation - Requires Your Action")
  end

  def match_initiation_for_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "New Housing Recommendation")
  end

  def hsa_accepts_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match ready for review - Requires Your Action")
  end

  def confirm_hsa_decline_dnd_staff notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Declined by #{_('HSA')} - Requires Your Action")
  end

  def hsa_decision_client notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def hsa_decision_shelter_agency notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def hsa_decision_ssp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def hsa_decision_hsp notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  # End Provider Only

  # Progress Updates
  def progress_update_requested notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Progress Update Requested - Requires Your Action")
  end

  def progress_update_submitted notification
    setup_instance_variables notification
    mail(to: @contact.email, subject: "Match Progress Update Submitted")
  end

  def dnd_progress_update_late notification, contact, matches
    @notification = notification
    @matches = matches
    @contact = contact
    mail(to: @contact.email, subject: "Match Progress Late")
  end
  
end
