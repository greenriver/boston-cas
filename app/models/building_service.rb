class BuildingService < ActiveRecord::Base
  belongs_to :building, required: :true, inverse_of: :building_services
  belongs_to :service, required: :true, inverse_of: :building_services
end
