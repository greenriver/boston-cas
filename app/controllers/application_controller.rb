###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

require "application_responder"

class ApplicationController < ActionController::Base
  include ControllerAuthorization
  self.responder = ApplicationResponder
  respond_to :html, :js, :json, :csv
  impersonates :user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  auto_session_timeout User.timeout_in
  prepend_before_action :skip_timeout

  helper_method :locale
  before_action :set_gettext_locale
  before_action :set_hostname

  #before_action :_basic_auth, if: -> { Rails.env.staging? }
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!
  # Allow devise login links to pass along a destination
  after_action :store_current_location, :unless => :devise_controller?

  if Rails.configuration.force_ssl
    force_ssl
  end

  private

  def _basic_auth
    authenticate_or_request_with_http_basic do |user, password|
      user == Rails.application.secrets.basic_auth_user && \
      password == Rails.application.secrets.basic_auth_password
    end
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  def append_info_to_payload(payload)
    super
    payload[:server_protocol] = request.env['SERVER_PROTOCOL']
    payload[:forwarded_for] = request.headers['HTTP_X_FORWARDED_FOR']
    payload[:remote_ip] = request.remote_ip
    payload[:session_id] = request.env['rack.session.record'].try(:session_id)
    payload[:user_id] = current_user&.id
    payload[:pid] = Process.pid
    payload[:request_id] = request.uuid
    payload[:request_start] = request.headers['HTTP_X_REQUEST_START'].try(:gsub, /\At=/,'')
  end

  def info_for_paper_trail
    {
      user_id: warden&.user&.id,
      notification_code: params[:notification_id],
      session_id: request.env['rack.session.record']&.session_id,
      request_id: request.uuid
    }
  end

  # Sets whodunnit
  def user_for_paper_trail
    return 'unauthenticated' unless current_user.present?
    return current_user.id unless true_user.present?
    return current_user.id if true_user == current_user

    "#{true_user.id} as #{current_user.id}"
  end

  def after_sign_in_path_for(resource)
    # alert users if their password has been compromised
    set_flash_message! :alert, :warn_pwned if resource.respond_to?(:pwned?) && resource.pwned?
    super
  end

  def current_contact
    @current_contact || current_user.try(:contact)
  end

  def store_current_location
    return unless request.get?
    return if request.xhr? # don't store ajax calls
    store_location_for(:user, request.url)
  end

  def set_gettext_locale
    session[:locale] = I18n.locale = FastGettext.set_locale(locale)
    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation, :name])
  end

  def filter_terms
    [  ]
  end
  helper_method :filter_terms

  def locale
    default_locale = 'en'
    params[:locale] || session[:locale] || default_locale
  end

  # don't extend the user's session if its an ajax request.
  def skip_timeout
    request.env['devise.skip_trackable'] = true if request.xhr?
  end

  def set_hostname
    @op_hostname ||= `hostname` rescue 'test-server'
  end
end
