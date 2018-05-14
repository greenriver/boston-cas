require "application_responder"

class ApplicationController < ActionController::Base
  include ControllerAuthorization
  self.responder = ApplicationResponder
  respond_to :html, :js, :json, :csv
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  auto_session_timeout User.timeout_in
  prepend_before_action :skip_timeout

  helper_method :locale
  before_filter :set_gettext_locale

  #before_filter :_basic_auth, if: -> { Rails.env.staging? }
  before_filter :set_paper_trail_whodunnit
  before_action :authenticate_user!
  # Allow devise login links to pass along a destination
  after_filter :store_current_location, :unless => :devise_controller?

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
      user_id: current_user&.id,
      notification_code: params[:notification_id],
      session_id: request.env['rack.session.record']&.session_id,
      request_id: request.uuid
    }
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
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :name) }
  end

  def locale
    default_locale = 'en'
    params[:locale] || session[:locale] || default_locale
  end

  # don't extend the user's session if its an ajax request.
  def skip_timeout
    request.env['devise.skip_trackable'] = true if request.xhr?
  end
end
