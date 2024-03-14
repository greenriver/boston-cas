###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class HousingAttributesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_housingable # Must be defined on the child class
  before_action :set_attribute, only: [:edit, :update, :destroy]

  include AjaxModalRails::Controller

  def index
  end

  def new
    @attribute = @housingable.housing_attributes.build
  end

  def create
    @housingable.housing_attributes.where(attribute_params).first_or_create
    redirect_to edit_polymorphic_path(@housingable)
  end

  def edit
  end

  def update
    @attribute.update(attribute_params)
    redirect_to edit_polymorphic_path(@housingable)
  end

  def destroy
    @attribute.destroy

    flash[:notice] = "Attribute '#{@attribute.name}' removed"
    redirect_to edit_polymorphic_path(@housingable)
  end

  def values
    attribute_name = params[:attribute_name]
    @data = []

    @data = HousingAttribute.new.existing_values(for_attribute: attribute_name) if attribute_name.present?
    render layout: false
  end

  def set_attribute
    @attribute = HousingAttribute.find(params[:id].to_i)
  end

  def attribute_params
    params.require(:housing_attribute).permit(
      :name,
      :value,
      "#{@housingable.class.name.downcase}_id",
    )
  end
end
