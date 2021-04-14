###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NonHmisAssessmentsController < ApplicationController
  before_action :set_client
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]
  before_action :set_neighborhoods

  def index
    @assessments = NonHmisAssessment.where(non_hmis_client_id: @non_hmis_client.id)
  end

  def new
    @assessment = build_assessment
  end

  def create
    @assessment = build_assessment
    @assessment.update(@assessment.assessment_params(params))
    if @assessment.save
      redirect_to @non_hmis_client
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @assessment.update(@assessment.assessment_params(params))
      redirect_to @non_hmis_client
    else
      render :edit
    end
  end

  def destroy
    flash[:notice] = 'Assessment successfully deleted.' if @assessment.destroy

    redirect_to @non_hmis_client
  end

  private def build_assessment
    @non_hmis_client.assessment_type.constantize.new
  end

  private def set_client
    # FIXME permissions
    client_id = (params[:identified_client_id] || params[:deidentified_client_id]).to_i
    @non_hmis_client = NonHmisClient.visible_to(current_user).find(client_id)
  end

  private def set_assessment
    # FIXME permissions
    @assessment = NonHmisAssessment.find(params[:id].to_i)
  end

  private def set_neighborhoods
    @neighborhoods = Neighborhood.order(:name).pluck(:id, :name)
  end
end