###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteThirteenMailerMethods
  extend ActiveSupport::Concern
  included do
    def thirteen_client_match(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def thirteen_match_acknowledgement_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def thirteen_match_acknowledgement_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation')
    end

    def thirteen_client_review_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Acknowledged - Requires Your Action')
    end

    def thirteen_client_review_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Acknowledged')
    end

    def thirteen_client_review_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Acknowledged')
    end

    def thirteen_client_review_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('Shelter Agency Thirteen')} - Requires Your Action")
    end

    def thirteen_hearing_scheduled_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Accepted by #{Translation.translate('Shelter Agency Thirteen')}")
    end

    def thirteen_hearing_scheduled_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Accepted by #{Translation.translate('Shelter Agency Thirteen')} - Requires Your Action")
    end

    def thirteen_hearing_scheduled_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Accepted by #{Translation.translate('Shelter Agency Thirteen')}")
    end

    def thirteen_hearing_scheduled_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_hearing_outcome_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Review Scheduled by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_hearing_outcome_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Review Scheduled by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_hearing_outcome_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Review Scheduled by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_hearing_outcome_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_hsa_review_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_hsa_review_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_hsa_review_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_hsa_review_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_accept_referral_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_accept_referral_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_accept_referral_ssp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_accept_referral_hsp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Ready for Review by #{Translation.translate('HSA Thirteen')}")
    end

    def thirteen_accept_referral_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Thirteen')} - Requires Your Action")
    end

    def thirteen_confirm_match_success_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Success Confirmed')
    end

    def thirteen_confirm_match_success_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Success Confirmed')
    end

    def thirteen_confirm_match_success_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Success Confirmed')
    end
  end
end
