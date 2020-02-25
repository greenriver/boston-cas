###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

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
    redirect_to(root_path, alert: 'Sorry you are not authorized to do that.')
  end

  def require_can_see_some_alternate_matches!
      not_authorized! unless can_see_alternate_matches? || can_see_all_alternate_matches?
  end
end