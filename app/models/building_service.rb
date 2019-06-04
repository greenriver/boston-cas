###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class BuildingService < ActiveRecord::Base
  belongs_to :building, required: :true, inverse_of: :building_services
  belongs_to :service, required: :true, inverse_of: :building_services
end
