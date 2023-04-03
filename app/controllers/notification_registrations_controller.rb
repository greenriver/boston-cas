###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NotificationRegistrationsController < Devise::RegistrationsController
  before_action :load_notification!
  before_action :ensure_notification_allows_registration!
  before_action :load_contact!
  before_action :ensure_contact_has_no_user!

  def new
    @user = @contact.build_user
  end

  def create
    @user = User.new(email: @contact.email, name: @contact.full_name)
    role = @notification.registration_role
    if role.present?
      @user[role] = true
    end
    @user.invite!
    flash[:notice] = "Please check your email for login information."
    redirect_to new_notification_session_path(@notification)
  end

  private def load_notification!
    @notification = Notifications::Base.find_by code: params[:notification_id]
  end

  private def load_contact!
    @contact = @notification.recipient
    raise ActiveRecord::NotFound unless @contact
  end

  private def ensure_contact_has_no_user!
    if @contact.user
      flash[:alert] = "You already have an account.  Please login or use the Reset Account Password form below."
      redirect_to new_notification_session_path(@notification)
    end
  end

  private def ensure_notification_allows_registration!
    unless @notification.allows_registration?
      flash[:alert] = "Sorry, you do not have authorization to create an account.  Please contact #{_('DND')}."
      redirect_to new_notification_session_path(@notification)
    end
  end




end
