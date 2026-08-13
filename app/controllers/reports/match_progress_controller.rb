###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
          @included_sub_programs = sub_program_list.filter { |_name, sp_id| sp_id.in?(report_params[:sub_programs]) }
          filename = 'CAS Match Progress.xlsx'
          render xlsx: 'index', filename: filename
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
        next unless event.include_in_tracking_sheet?

        steps[step_number] ||= []
        steps[step_number].push(*event.tracking_events) if event.include_tracking_event?
        step_number = event.next_step_number(step_number)
      end
      steps
    end

    def clients(sub_program_id)
      Client.
        visible_by(current_user).
        joins(client_opportunity_matches: { opportunity: :voucher }).
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
        joins(:program, :match_route).
        preload(:program, :match_route).
        order(p_t[:name].asc, sp_t[:name].asc, id: :asc).
        map do |sp|
          {
            program: sp.program.name,
            sub_program: sp.name,
            route: sp.match_route.title,
            id: sp.id,
          }
        end
    end

    def sub_program_list
      @sub_program_list ||= sub_programs.map do |sp|
        [
          [sp[:program], sp[:sub_program], sp[:route]].compact_blank.join('|'),
          sp[:id],
        ]
      end.uniq
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
