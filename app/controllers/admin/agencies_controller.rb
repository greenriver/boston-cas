###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Admin
  class AgenciesController < ApplicationController
    before_action :require_can_edit_users!
    before_action :set_agency, only: [:edit, :update, :destroy]
    before_action :set_editable_programs, only: [:edit, :update]

    def index
      @agencies = if params[:q].present?
        agency_scope.text_search(params[:q])
      else
        agency_scope
      end

      @agencies = @agencies.page(params[:page])
    end

    def new
      @agency = Agency.new
    end

    def create
      if @agency = Agency.create(agency_params)
        requested_programs = programs_params[:editable_programs].reject(&:blank?).map(&:to_i)
        requested_programs.each do |program_id|
          EntityViewPermission.create(entity: Program.find(program_id), agency: @agency, editable: true)
        end
        flash[:notice] = "#{@agency.name} was successfully added."
        redirect_to admin_agencies_path
      else
        render :new
      end
    end

    def edit

    end

    def update
      if @agency.update(agency_params)
        requested_programs = programs_params[:editable_programs].reject(&:blank?).map(&:to_i)
        update_editable_programs(requested_programs)
        flash[:notice] = "#{@agency.name} was successfully updated."
        redirect_to admin_agencies_path
      else
        render :edit
      end
    end

    def destroy
      @agency.destroy
      flash[:notice] = "#{@agency.name} was successfully deleted."
      redirect_to admin_agencies_path
    end

    def update_editable_programs(requested_programs)
      removed_programs = @editable_programs - requested_programs
      removed_programs.each do |program_id|
        EntityViewPermission.where(entity: Program.find(program_id), agency: @agency).destroy_all
      end

      added_programs = requested_programs - @editable_programs
      added_programs.each do |program_id|
        EntityViewPermission.create(entity: Program.find(program_id), agency: @agency, editable: true)
      end
    end


    def set_agency
      @agency = agency_scope.find(params[:id].to_i)
    end

    def agency_params
      params.require(:agency)
        .permit(
          :name,
        )
    end

    def programs_params
      params.require(:agency).permit(
        editable_programs: [],
      )
    end

    def agency_scope
      Agency.
        includes(:users).
        preload(:users).
        order(:name)
    end

    def set_editable_programs
      @editable_programs = Program.editable_by_agency(@agency).pluck(:entity_id)
    end
  end
end