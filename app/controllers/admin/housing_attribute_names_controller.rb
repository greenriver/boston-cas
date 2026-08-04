###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class HousingAttributeNamesController < ApplicationController
    before_action :require_can_manage_config!
    before_action :set_row, only: [:edit, :update]

    def index
      @names = HousingAttribute.name_summary
    end

    def edit
      @rows = HousingAttribute.where(name: @row.name, include_value: @row.include_value).
        includes(:housingable).order(:housingable_type, :housingable_id)
      @values = @row.include_value? ? HousingAttribute.value_summary(@row.name) : []
    end

    def update
      old_name = @row.name
      new_name = attribute_params[:name].presence || old_name

      HousingAttribute.rename(old_name: old_name, new_name: new_name, include_value: @row.include_value)

      if @row.include_value?
        Array(attribute_params[:value_renames]).each do |pair|
          HousingAttribute.rename_value(name: new_name, old_value: pair[:old_value], new_value: pair[:new_value])
        end
      end

      flash[:notice] = new_name == old_name ? "Updated '#{new_name}'" : "Renamed '#{old_name}' to '#{new_name}'"
      redirect_to edit_admin_housing_attribute_name_path(@row.id)
    end

    private

    def set_row
      @row = HousingAttribute.find(params[:id].to_i)
    end

    def attribute_params
      params.require(:housing_attribute_name).permit(:name, value_renames: [:old_value, :new_value])
    end

    def housingable_type(housingable)
      case housingable
      when Building then 'Building'
      when Unit then 'Unit'
      end
    end
    helper_method :housingable_type

    def housingable_name(housingable)
      case housingable
      when Building then housingable.name
      when Unit then "#{housingable.name} (#{housingable.building&.name})"
      end
    end
    helper_method :housingable_name

    def housingable_edit_path(housingable)
      case housingable
      when Building then edit_building_path(housingable)
      when Unit then edit_unit_path(housingable)
      end
    end
    helper_method :housingable_edit_path
  end
end
