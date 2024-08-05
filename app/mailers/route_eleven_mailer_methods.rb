###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteElevenMailerMethods
  extend ActiveSupport::Concern
  included do
    def eleven_confirm_hsa_decline_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('HSA Eleven')} - Requires Your Action")
    end

    def eleven_hsa_accepts_client_ssp_notification(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match accepted by #{Translation.translate('HSA Eleven')}")
    end

    def eleven_hsa_accepts_client(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match ready for review - Requires Your Action')
    end

    def eleven_hsa_decision_client(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Decision from #{Translation.translate('Housing Subsidy Administrator Eleven')}")
    end

    def eleven_hsa_decision_hsp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Decision from #{Translation.translate('Housing Subsidy Administrator Eleven')}")
    end

    def eleven_hsa_decision_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Decision from #{Translation.translate('Housing Subsidy Administrator Eleven')}")
    end

    def eleven_hsa_decision_ssp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Decision from #{Translation.translate('Housing Subsidy Administrator Eleven')}")
    end

    def eleven_match_initiation_for_hsa(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def eleven_match_initiation_for_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation')
    end

    def eleven_match_initiation_for_ssp(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation')
    end
  end
end
