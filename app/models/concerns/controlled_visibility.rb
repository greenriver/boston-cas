module ControlledVisibility
  extend ActiveSupport::Concern

  included do
    has_many :entity_view_permissions, as: :entity

    scope :visible_for, -> (user) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
          evp_t[:user_id].eq(user.id)
      )
    }

    scope :editable_for, -> (user) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
          evp_t[:user_id].eq(user.id),
          evp_t[:editable].eq(true)
      )
    }
  end

  def visible_for? user
    entity_view_permissions.where(user: user).present?
  end

  def editable_for? user
    entity_view_permissions.where(user: user, editable: true).present?
  end
end