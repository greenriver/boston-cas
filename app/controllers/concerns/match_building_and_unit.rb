module MatchBuildingAndUnit
  extend ActiveSupport::Concern

  included do
    def notification_id
      params[:notification_id]
    end
    helper_method :notification_id

    def has_unit?
      voucher.unit
    end
    helper_method :has_unit?

    def default_building_id
      voucher.unit.building
    end
    helper_method :default_building_id

    def default_unit_id
      voucher.unit.id
    end
    helper_method :default_unit_id

    def default_unit_name
      voucher.unit.name
    end
    helper_method :default_unit_name

    def candidate_units
      units = [ Unit.find(default_unit_id) ]
      units += voucher.units.select{|u| !u.in_use? }
    end
    helper_method :candidate_units

    private def voucher
      match.opportunity.voucher
    end
  end

end