class MoveEntityViewPermissionsToAgencies < ActiveRecord::Migration[6.0]
  def up
    EntityViewPermission.find_each do |permission|
      agency = permission.user.agency
      EntityViewPermission.where(agency: agency, entity: permission.entity).first_or_create(editable: permission.editable)
    end
  end

  def down
    EntityViewPermission.where(user_id: nil).delete_all
  end
end
