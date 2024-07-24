###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteTwelveMailerMethods
  extend ActiveSupport::Concern
  included do
    def twelve_agency_acknowledges_receipt(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def twelve_agency_acknowledges_receipt_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('Shelter Agency Ten')} - Requires Your Action")
    end

    def twelve_hsa_confirm_match_success(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def twelve_hsa_confirm_match_success_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{Translation.translate('Shelter Agency Ten')} - Requires Your Action")
    end

    def twelve_confirm_match_success_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end
  end
end
