class SubgranteesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!
  before_action :set_subgrantee, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  
  # GET /hmis/subgrantees
  def index
    # search
    @subgrantees = if params[:q].present?
      subgrantee_scope.text_search(params[:q])
    else
      subgrantee_scope
    end

    # sort / paginate
    @subgrantees = @subgrantees
      .order(sort_column => sort_direction)
      .page(params[:page]).per(25)
  end

  def new
    @subgrantee = Subgrantee.new
  end

  def create
    if @subgrantee = Subgrantee.create(subgrantee_params)
      flash[:notice] = "#{@subgrantee.name} was successfully added."
      redirect_to subgrantee_path @subgrantee
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @subgrantee.update(subgrantee_params)
      flash[:notice] = "#{@subgrantee.name} was successfully updated."
      redirect_to subgrantee_path @subgrantee
    else
      render :edit
    end
  end

  def show
    @buildings = building_scope.page(params[:page]).per(15).where(subgrantee_id: @subgrantee).order(:id)
  end

  private
    def subgrantee_scope
      Subgrantee
    end
  
    def building_scope
      Building
    end

    # Only allow a trusted parameter "white list" through.
    def subgrantee_params
      params_base = params[:subgrantee] || ActionController::Parameters.new
      params_base.permit(
        :name,
        service_ids: [],
        requirements_attributes: [:id, :rule_id, :positive, :_destroy]
      )
    end
    
    def set_subgrantee
      @subgrantee = subgrantee_scope.find(params[:id])
    end
    
    def sort_column
      Subgrantee.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{@query}%"
    end
end
