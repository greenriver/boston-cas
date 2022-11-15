###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ProgramsController < ApplicationController
  include ProgramPermissions
  before_action :authenticate_user!
  before_action :require_can_edit_programs!, only: [:create]

  helper_method :sort_column, :sort_direction

  def index
    # search
    @programs = if params[:q].present?
      sub_program_scope.text_search(params[:q])
    else
      sub_program_scope
    end

    # sort / paginate
    sort_string = sorter

    @sorted_by = Program.sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    @available_routes = MatchRoutes::Base.filterable_routes
    @current_route = params[:current_route]
    @programs = @programs.joins(:match_route).where(match_routes: { type: @current_route }) if @current_route.present? && MatchRoutes::Base.filterable_routes.values.include?(@current_route)

    @active_filter = @current_route.present?

    @include_closed = params[:include_closed]
    if @include_closed.blank?
      @programs = @programs.open
    else
      @programs = @programs.closed
    end

    @programs = @programs.
      joins(:program).
      includes(:building).
      references(:building).
      preload(:program).
      reorder(sort_string)

    respond_to do |format|
      format.html do
        @programs = @programs.page(params[:page]).per(25)
      end
      format.xlsx do
        filename = "CAS Programs-#{Date.current.strftime('%Y-%m-%d')}.xlsx"
        headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def new
    @program = program_source.new(sub_programs: [SubProgram.new({ program_type: 'Project-Based' })])
  end

  def create
    @program = Program.new program_params
    if @program.save
      EntityViewPermission.create(entity: @program, user: current_user, editable: true)
      # there should only be one sub-program immediately after a program create
      @sub_program = @program.sub_programs.first
      redirect_to action: :index
      flash[:notice] = "New program \"<a href=\"#{edit_program_sub_program_path(@program, @sub_program)}\">#{@program.name}</a>\" created"
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end

  private def program_source
    Program
  end

  private def program_params
    params.require(:program).
      permit(
        :name,
        :description,
        :contract_start_date,
        :funding_source_id,
        :confidential,
        :match_route_id,
        warehouse_project_ids: [],
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
        requirements_attributes: [
          :id,
          :rule_id,
          :positive,
          :variable,
          :_destroy,
        ],
      )
  end

  private def adding_sub_program
    program_params[:sub_program].present?
  end

  private def sort_column
    return 'program_id' if params[:sort].blank?

    params[:sort]
  end

  private def sort_direction
    ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private def query_string
    "%#{@query}%"
  end

  private def filter_terms
    [:current_route]
  end
  helper_method :filter_terms

  private def sorter
    @column = params[:sort]
    @direction = params[:direction]

    if @column.blank?
      @column = 'program_id'
      @direction = 'asc'
      sort_string = "#{@column} #{@direction}"
    else
      sort_string = Program.sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.first[:order]
    end

    sort_string += ' NULLS LAST' if ApplicationRecord.connection.adapter_name == 'PostgreSQL'
    return sort_string
  end
end
