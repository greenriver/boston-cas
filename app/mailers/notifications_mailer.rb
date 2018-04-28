class NotificationsMailer < DatabaseMailer

  def match_recommendation_dnd_staff notification
    binding.pry
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Recommendation - Requires Your Action")
  end

  def match_recommendation_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Opportunity")
  end

  def match_recommendation_housing_subsidy_admin notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Recommendation")
  end

  def match_recommendation_ssp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Recommendation")
  end

  def match_recommendation_hsp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Recommendation")
  end

  def match_recommendation_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} New Housing Recommendation - Requires Your Action")
  end

  def schedule_criminal_hearing_housing_subsidy_admin notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation - Requires Your Action")
  end

  def schedule_criminal_hearing_ssp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation")
  end

  def schedule_criminal_hearing_hsp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation")
  end
  
  def record_client_housed_date_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation Approved - Requires Your Action")
  end

  def record_client_housed_date_housing_subsidy_administrator notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation Approved - Requires Your Action")
  end

  def move_in_date_set notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation Move-in Date Set")
  end
  
  def confirm_match_success_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Housing Recommendation - Requires Final Approval")
  end
  
  def criminal_hearing_scheduled_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Hearing Scheduled")
  end

  def criminal_hearing_scheduled_ssp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Hearing Scheduled")
  end

  def criminal_hearing_scheduled_hsp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Hearing Scheduled")
  end
  
  def criminal_hearing_scheduled_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Hearing Scheduled")
  end
  
  def criminal_hearing_scheduled_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Hearing Scheduled")
  end
  
  def housing_subsidy_admin_decision_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_ssp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end

  def housing_subsidy_admin_decision_hsp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "Decision from #{_('Housing Subsidy Administrator')}")
  end
  
  def housing_subsidy_admin_accepted_match_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Accepted by #{_('HSA')}")
  end
  
  def housing_subsidy_admin_declined_match_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Declined by #{_('HSA')}")
  end

  def housing_subsidy_admin_declined_match_ssp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Declined by #{_('HSA')}")
  end

  def housing_subsidy_admin_declined_match_hsp notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Declined by #{_('HSA')}")
  end

  def confirm_shelter_agency_decline_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Declined by #{_('Shelter Agency')} - Requires Your Action")
  end

  def confirm_housing_subsidy_admin_decline_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Declined by #{_('HSA')} - Requires Your Action")
  end

  def on_behalf_of notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Action taken on your behalf")
  end

  def no_longer_working_with_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Contact no longer working with Client")
  end

  def match_canceled notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Administratively Canceled")
  end

  def shelter_agency_accepted notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} #{_('Shelter Agency')} Accepted Match")
  end

  def shelter_agency_decline_accepted notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Decline Accepted")
  end

  def progress_update_requested notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Progress Update Requested - Requires Your Action")
  end

  def progress_update_submitted notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: "#{prefix} Match Progress Update Submitted")
  end

  def dnd_progress_update_late notification, contact, matches
    @notification = notification
    @matches = matches
    @contact = contact
    mail(to: @contact.email, subject: "#{prefix} Match Progress Late")
  end
  
end
