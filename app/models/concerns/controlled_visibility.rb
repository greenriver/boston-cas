module ControlledVisibility
  extend ActiveSupport::Concern

  included do
    has_many :entity_view_permissions, as: :entity

    scope :visible_for, -> (user) {
      EntityViewPermission.where(user: user)
    }
  end

  def visible_for? user
    entity_view_permissions.where(user: user).present?
  end
end