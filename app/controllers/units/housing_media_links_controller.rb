###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Units
  class HousingMediaLinksController < HousingMediaLinksController
    before_action :require_can_edit_units!

    def set_housingable
      @housingable = Unit.find(params[:unit_id].to_i)
    end
  end
end
