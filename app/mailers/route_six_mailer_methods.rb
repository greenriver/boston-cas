###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteSixMailerMethods
  extend ActiveSupport::Concern
  included do
    def six_approve_match_housing_subsidy_admin(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match accepted by #{Translation.translate('Shelter Agency Six')} - Requires Your Action")
    end

    def six_confirm_hsa_decline_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Six')} - Requires Your Action")
    end

    def six_confirm_match_success_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Housing Recommendation - Requires Final Approval')
    end

    def six_confirm_match_success_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Successful')
    end

    def six_confirm_shelter_agency_decline_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('Shelter Agency Six')} - Requires Your Action")
    end

    def six_match_recommendation_client(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Opportunity')
    end

    def six_match_recommendation_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def six_match_recommendation_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def six_shelter_agency_accepted(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "#{Translation.translate('Shelter Agency Six')} Accepted Match")
    end
  end
end
