###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteNineMailerMethods
  extend ActiveSupport::Concern
  included do
    def ten_agency_confirm_match_success(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'New Housing Recommendation - Requires Your Action')
    end

    def ten_agency_confirm_match_success_decline(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match Declined by #{_('Shelter Agency Ten')} - Requires Your Action")
    end

    def ten_confirm_match_success_dnd_staff(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: 'Match Successful')
    end
  end
end
