###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Units
  class HousingMediaLinksController < HousingMediaLinksController
    before_action :require_can_edit_units!

    def set_housingable
      @housingable = Unit.find(params[:unit_id].to_i)
    end
  end
end
