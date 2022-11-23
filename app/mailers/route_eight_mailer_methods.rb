###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteEightMailerMethods
  extend ActiveSupport::Concern
  included do
    # Match Route Eight
    def eight_match_recommendation
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def eight_record_voucher_date
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Housing Recommendation Approved - Requires Your Action')
    end

    def eight_match_in_progress
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'New Housing Recommendation')
    end

    def eight_confirm_hsa_decline
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match Declined by #{_('HSA Eight')} - Requires Your Action")
    end

    def eight_confirm_voucher_decline
      eight_confirm_hsa_decline
    end

    def eight_lease_up
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match is awaiting #{_('Move In')}")
    end

    def eight_confirm_lease_up_decline
      eight_confirm_hsa_decline
    end

    def eight_assign_case_contact
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Assign Case Contact - Requires Your Action')
    end

    def eight_assign_manager
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Assign Case Manager - Requires Your Action')
    end

    def eight_confirm_assign_manager_decline
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match Declined by #{_('Stabilization Service Provider Eight')} - Requires Your Action")
    end

    def eight_confirm_match_success
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Housing Recommendation - Requires Final Approval')
    end

    def eight_confirm_match_success
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match Successful')
    end
    # End Match Route Eight
  end
end
