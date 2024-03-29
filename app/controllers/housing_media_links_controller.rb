###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class HousingMediaLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_housingable # Must be defined on the child class
  before_action :set_media_link, only: [:destroy]

  include AjaxModalRails::Controller

  def index
  end

  def new
    @media_link = @housingable.housing_media_links.build
  end

  def create
    @media_link = @housingable.housing_media_links.where(media_link_params).first_or_create
    respond_with @media_link, location: edit_polymorphic_path(@housingable)
  end

  def destroy
    @media_link.destroy

    flash[:notice] = "Media Link '#{@media_link.label}' removed"
    redirect_to edit_polymorphic_path(@housingable)
  end

  def set_media_link
    @media_link = HousingMediaLink.find(params[:id].to_i)
  end

  def media_link_params
    params.require(:housing_media_link).permit(
      :url,
      :label,
      "#{@housingable.class.name.downcase}_id",
    )
  end

  def flash_interpolation_options
    { resource_name: 'Media link' }
  end
end
