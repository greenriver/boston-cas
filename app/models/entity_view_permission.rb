###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class EntityViewPermission < ApplicationRecord
  acts_as_paranoid

  belongs_to :entity, polymorphic: true
  belongs_to :user
  belongs_to :agency
end
