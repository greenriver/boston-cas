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

  def new
    @funding_source = funding_source_source.new
  end
  
  def create
    @funding_source = funding_source_source.create(funding_source_params)
    respond_with(@funding_source, location: funding_sources_path)
  end

  def update
    @funding_source.update funding_source_params
    respond_with(@funding_source, location: funding_sources_path)
  end
  
  private
    def funding_source_scope
      funding_source_source.all
    end

    def find_funding_source
      @funding_source = funding_source_source.find params[:id]
    end

    def funding_source_source
      FundingSource
    end
    
    def funding_source_params
      params.require(:funding_source).permit(
        :name,
        service_ids: [],
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
      )
    end
    
    
end