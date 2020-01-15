###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchAccessContexts
  class Notification

    attr_reader :controller, :notification

    def initialize controller
      @controller = controller
      @notification = Notifications::Base.find_by code: controller.params[:notification_id].to_s
    end

    def current_contact
      @notification.recipient
    end

    def contacts_editable?
      @notification.contacts_editable?
    end

    def acknowledge_shelter_agency_notification?
      true
    end

    def match_scope
      return ClientOpportunityMatch.none unless notification.present?

      ClientOpportunityMatch.where(id: notification.client_opportunity_match_id)
    end

    def authenticate!
      return false unless @notification.present?

      if @notification.expires_at.nil?
        return true
      elsif @notification.expired?
        controller.redirect_to controller.notification_reissue_request_path(@notification)
        return false
      else
        return true
      end
    end

    ################
    ### Path Helpers
    ################

    def match_path match, opts = {}
      controller.notification_match_path(@notification, match, opts)
    end

    def match_decision_path match, decision, opts = {}
      controller.notification_match_decision_path @notification, match, decision, opts
    end

    def match_decision_acknowledgment_path match, decision, opts = {}
      controller.notification_match_decision_acknowledgment_path @notification, match, decision, opts
    end

    def edit_match_contacts_path match, opts = {}
      controller.edit_notification_match_contacts_path @notification, match, opts
    end

    def match_contacts_path match, opts = {}
      controller.notification_match_contacts_path @notification, match, opts
    end

    def match_client_details_path match, opts = {}
      controller.notification_match_client_details_path @notification, match, opts
    end


  end
end
