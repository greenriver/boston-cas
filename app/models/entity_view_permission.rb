###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class EntityViewPermission < ApplicationRecord
  acts_as_paranoid

  belongs_to :entity, polymorphic: true
  belongs_to :user
  belongs_to :agency
end