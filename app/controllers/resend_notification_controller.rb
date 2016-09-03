class ResendNotificationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!

  def show
    @notification = Notifications::Base.find_by code: params[:id]
    @notification.deliver
    redirect_to request.referer
  end
end
