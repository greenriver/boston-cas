###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class BuildingContact < ApplicationRecord

  belongs_to :building, inverse_of: :building_contacts
  belongs_to :contact, inverse_of: :building_contacts

  include ContactJoinModel

  acts_as_paranoid

end
