###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Units
  class HousingAttributesController < HousingAttributesController
    before_action :require_can_edit_units!

    def set_housingable
      @housingable = Unit.find(params[:unit_id].to_i)
    end
  end
end
