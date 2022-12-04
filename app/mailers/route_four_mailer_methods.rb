###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteFourMailerMethods
  extend ActiveSupport::Concern
  included do
    def match_recommendation_hsa
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match ready for review - Requires Your Action')
    end

    def match_recommendation_to_hsa_for_ssp
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match ready for review')
    end

    def housing_subsidy_administrator_accepted
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match accepted by #{_('HSA')}")
    end

    def confirm_hsa_initial_decline_dnd_staff
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match Declined by #{_('HSA')} - Requires Your Action")
    end

    def match_success_confirmed
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match Success Confirmed')
    end

    def match_rejected
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match Rejected')
    end

    def match_declined
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match Declined')
    end
  end
end