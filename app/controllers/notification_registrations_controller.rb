###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

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
    @user[role] = true if role.present?
    @user.invite!
    flash[:notice] = 'Please check your email for login information.'
    redirect_to new_notification_session_path(@notification)
  end

  private def load_notification!
    @notification = Notifications::Base.find_by code: params[:notification_id]
  end

  private def load_contact!
    @contact = @notification.recipient
    raise ActiveRecord::RecordNotFound unless @contact
  end

  private def ensure_contact_has_no_user!
    return unless @contact.user

    flash[:alert] = 'You already have an account.  Please login or use the Reset Account Password form below.'
    redirect_to new_notification_session_path(@notification)
  end

  private def ensure_notification_allows_registration!
    return if @notification.allows_registration?

    flash[:alert] = "Sorry, you do not have authorization to create an account.  Please contact #{Translation.translate('DND')}."
    redirect_to new_notification_session_path(@notification)
  end
end
