###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###


module Reports
  class MatchProgressController < ApplicationController
    include ArelHelper

    before_action :authenticate_user!

    def index
      if params.dig(:match_progress).present? && sub_programs_chosen.blank?
        flash[:error] = 'Program is required'
        redirect_to(action: :index)
        return
      end
      respond_to do |format|
        format.html {}
        format.xlsx do
          @included_sub_programs = sub_program_list.invert.slice(*report_params[:sub_programs])
          filename = 'CAS Match Progress.xlsx'
          render xlsx: 'index.xlsx', filename: filename
        end
      end
    end

    def actions(sub_program_id)
      # {match_id => {decision_order => [[date, text], ...]}}
      matches = ClientOpportunityMatch.
        active.
        joins(opportunity: :voucher).
        merge(Voucher.where(sub_program_id: sub_program_id))

      matches.map do |match|
        [
          match.id,
          step_events(match),
        ]
      end.to_h
    end
    helper_method :actions

    private def step_events(match)
      step_number = 1
      steps = {}
      status_history = match.status_updates.complete.preload(:notification, :contact).to_a
      events = match.events.to_a
      all_events = (events + status_history).sort_by(&:created_at)
      all_events.each do |event|
        if event.include_in_tracking_sheet?
          steps[step_number] ||= []
          steps[step_number].push(*event.tracking_events) if event.include_tracking_event?
          step_number = event.next_step_number(step_number)
        end
      end
      steps
    end

    def clients(sub_program_id)
      Client.
        visible_by(current_user).
        joins(client_opportunity_matches: {opportunity: :voucher}).
        merge(ClientOpportunityMatch.active).
        merge(Voucher.where(sub_program_id: sub_program_id)).
        order(:last_name, :first_name).
        pluck(com_t[:id], :first_name, :last_name).
        map do |id, first_name, last_name|
          [id, "#{last_name}, #{first_name}"]
        end.to_h
    end
    helper_method :clients

    def step_names(sub_program_id)
      route = SubProgram.
        find(sub_program_id).
        match_route
      return [] unless route

      steps = route.class.match_steps.invert
      steps.values.map { |class_name| class_name.constantize.new.step_name }
    end
    helper_method :step_names

    def sub_programs
      @sub_programs ||= SubProgram.
        joins(:program).
        preload(:program).
        pluck(p_t[:name], sp_t[:name], :id).
        sort
    end
    helper_method :sub_programs

    def sub_program_list
      @sub_program_list ||= begin
        sub_programs.map do |project_name, sub_project_name, id|
          [
            [project_name, sub_project_name].join('|'),
            id,
          ]
        end.to_h
      end
    end
    helper_method :sub_program_list

    private def sub_programs_chosen
      params.dig(:match_progress, :sub_programs).select(&:presence)
    end

    private def report_params
      opts = params.require(:match_progress).
        permit(
          sub_programs: [],
        )
      opts[:sub_programs] = opts[:sub_programs].reject(&:blank?).map(&:to_i)
      opts
    end
  end
end
