###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module RouteSevenMailerMethods
  extend ActiveSupport::Concern
  included do
    def approve_match_housing_subsidy_admin_from_dnd(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "Match accepted by #{Translation.translate('DND')} - Requires Your Action")
    end

    def match_in_progress_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "A match is in progress with a #{Translation.translate('Housing Subsidy Administrator')}")
    end

    def match_success_shelter_agency(notification = nil)
      setup_instance_variables(notification)
      mail(to: @contact.email, subject: "A match was successful with a #{Translation.translate('Housing Subsidy Administrator')}")
    end
  end
end
