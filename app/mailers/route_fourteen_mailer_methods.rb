###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module RouteFourteenMailerMethods
  extend ActiveSupport::Concern
  included do
    def fourteen_initiate_match_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_match_acknowledgement_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_match_acknowledgement_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end

    def fourteen_match_acknowledgement_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Declined - Requires Your Review')
    end

    def fourteen_client_review_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_client_review_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end

    def fourteen_client_review_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Declined - Requires Your Review')
    end

    def fourteen_eligibility_screening_hsp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_eligibility_screening_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end

    def fourteen_eligibility_screening_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Declined - Requires Your Review')
    end

    def fourteen_subsidy_admin_screening_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_subsidy_admin_screening_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end

    def fourteen_subsidy_admin_screening_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Declined - Requires Your Review')
    end

    def fourteen_offer_unit_hsp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_offer_unit_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end

    def fourteen_offer_unit_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Declined - Requires Your Review')
    end

    def fourteen_confirm_match_success_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def fourteen_confirm_match_success_fyi(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Update')
    end
  end
end
