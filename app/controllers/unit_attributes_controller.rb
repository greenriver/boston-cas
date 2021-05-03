###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class UnitAttributesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_edit_units!
  before_action :set_unit
  before_action :set_attribute, only: [:edit, :update, "destroy"]

  include AjaxModalRails::Controller

  def new
    @attribute = @unit.unit_attributes.build
  end

  def create
    @unit.unit_attributes.create(create_attribute_params)
    redirect_to edit_unit_path(@unit)
  end

  def edit
  end

  def update
    @attribute.update(update_attribute_params)
    redirect_to edit_unit_path(@unit)
  end

  def destroy
    @attribute.destroy

    flash[:alert] = "Attribute '#{@attribute.name}' removed"
    redirect_to edit_unit_path(@unit)
  end

  def values
    attribute_name = params[:attribute_name]
    @data = []

    @data = UnitAttribute.new.existing_values(for_attribute: attribute_name) if attribute_name.present?
    render layout: false
  end

  def create_attribute_params
    params.require(:unit_attribute).permit(
      :name,
      :value,
    )
  end

  def update_attribute_params
    params.require(:unit_attribute).permit(
      :value,
    )
  end

  def set_attribute
    @attribute = UnitAttribute.find(params[:id].to_i)
  end

  def set_unit
    @unit = Unit.find(params[:unit_id].to_i)
  end
end