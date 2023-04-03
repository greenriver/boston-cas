###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class BuildingService < ApplicationRecord
  belongs_to :building, inverse_of: :building_services
  belongs_to :service, inverse_of: :building_services
end
