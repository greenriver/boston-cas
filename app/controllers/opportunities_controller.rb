###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class OpportunitiesController < ApplicationController
  require 'securerandom'

  before_action :authenticate_user!
  before_action :require_can_view_opportunities!, except: [:new, :create]
  before_action :require_can_edit_opportunities!, only: [:update, :destroy]
  before_action :require_can_view_opportunities_or_can_add_vacancies!, only: [:new, :create]
  before_action :set_opportunity, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  # GET /hmis/opportunities
  def index
    # routes
    @routes = MatchRoutes::Base.available
    @active_tab = params[:tab] || route_to_html_id(@routes.first)

    # search
    @opportunities = if params[:q].present?
      opportunity_scope.text_search(params[:q])
    else
      opportunity_scope
    end

    # filter status with whitelist
    @match_status = params[:status] if Opportunity.available_stati.include?(params[:status]) || nil

    if @match_status.present?
      @active_filter = true
      case @match_status
      when 'Match in Progress'
        @opportunities = matches_in_progress(@opportunities)
      when 'Available in the future'
        @opportunities = available_in_the_future(@opportunities)
      when 'Successful'
        @opportunities = successful_matches(@opportunities)
      when 'Available'
        # This is pretty nasty, but available is the negation of various situations
        @opportunities = @opportunities.
          where.not(id: matches_in_progress(@opportunities)).
          where.not(id: available_in_the_future(@opportunities)).
          where.not(id: successful_matches(@opportunities))
      end
    end

    # filter actives with count
    @max_actives = params[:max_actives].to_i

    unless @max_actives.zero?
      @active_filter = true
      @opportunities = @opportunities.joins(:active_matches)
        .group(:id)
        .having(nf('COUNT', [o_t[:id]]).lt(@max_actives))
      # "count(opportunities.id) < #{@max_actives}"
    end

    # sort / paginate
    route = route_from_tab(@active_tab)
    @opportunities = @opportunities.
      joins(:match_route).
      where(match_routes: {id: route}).
      order(sort_column => sort_direction).
      preload(:unit, :voucher).
      page(params[:page]).per(25)
  end

  # GET /hmis/opportunities/1
  def show
  end

  # GET /hmis/opportunities/new
  # Using this to bulk create units and associated vouchers
  def new
    @opportunity = Opportunity.new
    @programs = sub_program_scope.sort_by{|m| [m.program.name, m.name]}
    @buildings = building_scope
  end

  # GET /hmis/opportunities/1/edit
  def edit
  end

  # Bulk create available units with associated available vouchers
  def create
    @opportunity = Opportunity.new(opportunity_params)

    if params[:opportunity][:program].blank?
      @opportunity.errors[:program] = 'Required'
    else
      sub_program = SubProgram.find(opportunity_params[:program].to_i)
    end

    if sub_program.present? && sub_program.has_buildings?
      if params[:opportunity][:building].blank?
        @opportunity.errors[:building] = 'Required'
      else
         building = Building.find(opportunity_params[:building].to_i)
      end
    end
    if params[:opportunity][:units].blank? || ! params[:opportunity][:units] =~ /\A\d+\z/
      @opportunity.errors[:units] = 'Required, and must be a number'
    end

    if @opportunity.errors.present?
      @programs = sub_program_scope
      @buildings = building_scope
      render :new
    else
      units = []
      vouchers = []
      opportunity_params[:units].to_i.times do |x|
        if sub_program.has_buildings?
          unit = Unit.create(building: building, name: SecureRandom.hex, available: true)
        end
        voucher = Voucher.new(sub_program: sub_program, available: true, creator: @current_user)
        voucher.unit = unit
        voucher.save!
        voucher.create_opportunity(available: true, available_candidate: true)

        vouchers << voucher
      end
      if vouchers.count > 0
        flash[:notice] = "Created #{vouchers.count} new #{Opportunity.model_name.human(count: vouchers.count)}"
        Matching::RunEngineJob.perform_later
        sub_program.update_summary!
      else
        flash[:alert] = "There was an error creating new #{Opportunity.model_name.human}"
      end
      if can_view_opportunities?
        redirect_to action: :index
      else
        redirect_to active_matches_path
      end
    end
  end

  # PATCH/PUT /hmis/opportunities/1
  def update
    if @opportunity.update(opportunity_params)
      redirect_to opportunity_path(@opportunity), notice: "Opportunity <strong>#{@opportunity[:id]}</strong> was successfully updated."
    else
      render :edit, {flash: {error: 'Unable to update opportunity <strong>#{@opportunity[:name]}</strong>.'}}
    end
  end

  # DELETE /hmis/opportunities/1
  def destroy
    if @opportunity.destroy
      redirect_to opportunities_path, notice: "Opportunity <strong>#{@opportunity[:id]}</strong> was successfully deleted."
    else
      render :edit, {flash: { error: 'Unable to delete opportunity <strong>#{@opportunity[:name]}</strong>.'}}
    end
  end

  # RESTORE /hmis/opportunities/1
  def restore
    if Opportunity.restore(params[:opportunity_id])
      @opportunity = Opportunity.find(params[:opportunity_id])
      redirect_to opportunities_path, notice: "Opportunity <strong>#{@opportunity[:id]}</strong> successfully restored."
    else
      render :edit, {:flash => { :error => 'Unable to restore opportunity.'}}
    end
  end

  def get_opportunity
    @opportunity = Opportunity.find(params[:id])
  end


  private def opportunity_scope
    Opportunity.where(success: false, available: true).
      joins(:voucher).
      where(vouchers: {available: true})
  end
  # Use callbacks to share common setup or constraints between actions.
  private def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  private def opportunity_params
    params.require(:opportunity)
      .permit(
        :available,
        :unit,
        :voucher,
        :client,
        :program,
        :building,
        :units,
      )
  end

  def filter_params
    params.permit(
      :sort,
      :direction,
      :q,
      :tab,
      :status,
      :max_actives,
    )
  end
  helper_method :filter_params

  def route_to_html_id(route)
    route.title.parameterize.dasherize
  end
  helper_method :route_to_html_id

  def route_from_tab(tab_label)
    @routes ||= MatchRoutes::Base.available
    @routes.each do |route|
      return route if route_to_html_id(route) == tab_label
    end
  end

  # TODO: limit to programs you are associated with
  private def sub_program_scope
    SubProgram.all
  end

  # TODO: limit to buildings you are associated with
  private def building_scope
    Building.all
  end

  private def sort_column
    Opportunity.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  private def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  private def query_string
    "%#{@query}%"
  end
  private def require_can_view_opportunities_or_can_add_vacancies!
    can_view_opportunities? || can_add_vacancies?
  end

  private def successful_matches(opportunities)
    opportunities.joins(:successful_match).distinct
  end

  private def matches_in_progress(opportunities)
    opportunities.joins(:active_matches).distinct
  end

  private def available_in_the_future(opportunities)
    opportunities.joins(:voucher).where(v_t[:date_available].gt(Date.today)).distinct
  end

  def filter_terms
    [
      :status,
      :max_actives,
      :tab,
    ]
  end
  helper_method :filter_terms
end
