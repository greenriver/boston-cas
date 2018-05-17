module ControllerAuthorization
  extend ActiveSupport::Concern
  delegate *Role.permissions.map{|m| "#{m}?".to_sym}, to: :current_user, allow_nil: true

  # This builds useful methods in the form:
  # require_permission!
  # such as require_can_edit_users!
  # It then checks the appropriate permission against the current user throwing up 
  # an alert if access is blocked
  Role.permissions.each do |permission|
    define_method("require_#{permission}!") do
      not_authorized! unless current_user.send("#{permission}?".to_sym)
    end
  end

  def not_authorized!
    flash[:alert] =  'Sorry you are not authorized to do that.'
    redirect_to root_path()
  end
end