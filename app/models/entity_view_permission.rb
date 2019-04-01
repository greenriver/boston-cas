class EntityViewPermission < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :entity, polymorphic: true
  belongs_to :user
end
