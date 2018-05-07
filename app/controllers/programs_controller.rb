class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_programs!
  before_action :require_can_edit_programs!, only: [:update, :destroy, :create]
  before_action :set_program, only: [:edit, :update, :destroy]
  
  helper_method :sort_column, :sort_direction

  def index
    # search
    @programs = if params[:q].present?
      sub_program_scope.text_search(params[:q])
    else
      sub_program_scope
    end

    # sort / paginate
    column = "sub_programs.#{sort_column}"
    if sort_column == 'program_id'
      column = 'programs.name'
    elsif sort_column == 'building_id'
      column = 'buildings.name'
    end
    sort = "#{column} #{sort_direction}"
    @programs = @programs
      .includes(:program)
      .references(:program)
      .includes(:building)
      .references(:building)
      .preload(:program)
      .order(sort)
      .page(params[:page]).per(25)

  end


  def new
    @program = program_source.new(sub_programs: [SubProgram.new({program_type: 'Project-Based'})])
  end

  def create
    @program = Program.new program_params
    if @program.save
      # there should only be one sub-program immediately after a program create
      @sub_program = @program.sub_programs.first
      redirect_to action: :index
       flash[:notice] = "New program \"<a href=\"#{edit_program_sub_program_path(@program, @sub_program)}\">#{@program.name}</a>\" created"
    else
      flash[:error] = "Please review the form problems below."
      render :new
    end
  end


  private
  def program_source
    Program
  end
  def program_scope
    Program.all
  end
  def sub_program_scope
    SubProgram
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_program
    @program = program_scope.find(params[:id])
  end

  def program_params
    params.require(:program).
      permit(
        :name, 
        :contract_start_date, 
        :funding_source_id, 
        :confidential,
        :match_route_id,
        sub_programs_attributes: [
          :id, 
          :name, 
          :subgrantee_id, # Service provider
          :sub_contractor_id,
          :program_type, 
          :building_id, 
          :hsa_id,
          :confidential,
          :eligibility_requirement_notes,
        ],
        service_ids: [],
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
      )
  end

  def adding_sub_program
    program_params[:sub_program].present?
  end

  def sort_column
    SubProgram.column_names.include?(params[:sort]) ? params[:sort] : 'program_id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def query_string
    "%#{@query}%"
  end
end
