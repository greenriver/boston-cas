module ControllerAuthorization
  extend ActiveSupport::Concern

  delegate :admin?, :dnd_staff?, :housing_subsidy_admin?, to: :current_user, allow_nil: true

  def not_authorized!
    redirect_to root_path, alert: 'Sorry you are not authorized to do that.'
  end

  def require_admin!
    not_authorized! unless admin?
  end

  def require_admin_or_dnd_staff!
    not_authorized! unless admin? || dnd_staff?
  end

  def require_add_vacancies!
    not_authorized! unless admin? || dnd_staff? || housing_subsidy_admin?
  end

end