###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Admin
  class LocationsController < ::ApplicationController
    before_action :require_can_audit_users!

    def show
      @user = User.find params[:user_id]
      @locations = @user.login_activities.order(created_at: :desc).
        page(params[:page]).per(50)
    end
  end
end
