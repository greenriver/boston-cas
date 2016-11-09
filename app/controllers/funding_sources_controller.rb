class FundingSourcesController < ApplicationController

  before_action :authenticate_user!
  before_action :require_can_view_funding_sources!
  before_action :require_can_edit_funding_sources!, only: [:update, :destroy, :create]
  before_action :find_funding_source, only: [:edit, :update]
  
  def index
    # search
    @funding_sources = if params[:q].present?
      funding_source_scope.text_search(params[:q])
    else
      funding_source_scope
    end

    @funding_sources = @funding_sources
      .page(params[:page]).per(25)
  end
  
  def edit
  end
  
  def update
    if @funding_source.update funding_source_params
      flash[:notice] = "Funding Source saved"
      redirect_to action: :index
    else
      flash[:alert] = 'Please correct the errors below'
      render :edit
    end
  end
  
  private
    def funding_source_scope
      FundingSource.all
    end

    def find_funding_source
      @funding_source = FundingSource.find params[:id]
    end
    
    def funding_source_params
      params.require(:funding_source).permit(
        service_ids: [],
        requirements_attributes: [:id, :rule_id, :positive, :_destroy]
      )
    end
    
    
end