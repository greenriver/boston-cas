###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class BuildingContact < ApplicationRecord

  belongs_to :building, inverse_of: :building_contacts
  belongs_to :contact, inverse_of: :building_contacts

  include ContactJoinModel

  acts_as_paranoid

end
