###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RouteFiveMailerMethods
  extend ActiveSupport::Concern
  included do
    def match_recommendation
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match ready for review - Requires Your Action')
    end

    def client_agrees
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match ready for review - Requires Your Action')
    end

    def submit_application
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match ready for review')
    end

    def screening
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match is ready for client screening')
    end

    def mitigation
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match requires mitigation')
    end

    def lease_up
      notification = params[:notification]
      setup_instance_variables notification
      mail(to: @contact.email, subject: 'Match is awaiting move in')
    end
  end
end
