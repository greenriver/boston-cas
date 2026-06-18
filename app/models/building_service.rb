###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class BuildingService < ApplicationRecord
  belongs_to :building, inverse_of: :building_services
  belongs_to :service, inverse_of: :building_services
end
