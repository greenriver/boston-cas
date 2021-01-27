###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_manage_tags!
  before_action :set_tag, only: [:edit, :update, :destroy]

  def index
    @tags = if params[:q].present?
      tag_scope.text_search(params[:q])
    else
      tag_scope
    end

    @tags = @tags.page(params[:page])
  end

  def new
    @tag = Tag.new
  end

  def create
    if @tag = Tag.create(tag_params)
      flash[:notice] = "#{@tag.name} was successfully added."
      redirect_to tags_path
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @tag.update(tag_params)
      flash[:notice] = "#{@tag.name} was successfully updated."
      redirect_to tags_path
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    flash[:notice] = "#{@tag.name} was successfully deleted."
    redirect_to tags_path
  end

  def set_tag
    @tag = tag_scope.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :rrh_assessment_trigger)
  end

  def tag_scope
    Tag.order(:name)
  end

end
