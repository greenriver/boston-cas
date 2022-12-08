###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteSixMailerMethods
  extend ActiveSupport::Concern
  included do
    def approve_match_housing_subsidy_admin
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: "Match accepted by #{_('Shelter Agency')} - Requires Your Action")
    end

    def confirm_match_success_shelter_agency
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match Successful')
    end
  end
end
