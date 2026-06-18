###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Buildings
  class HousingAttributesController < HousingAttributesController
    before_action :require_can_edit_buildings!

    def set_housingable
      @housingable = Building.find(params[:building_id].to_i)
    end
  end
end
