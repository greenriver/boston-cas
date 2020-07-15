###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/production/LICENSE.md
###

module Reports
  class MatchProgressController < ApplicationController
    include ArelHelper

    before_action :authenticate_user!

    def index
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
        joins(:opportunity).
        merge(Opportunity.joins(:voucher).
          merge(Voucher.where(sub_program_id: sub_program_id)))

      matches.map do |match|
        [
          match.id,
          begin
            decision_order = 1
            steps = {}
            match.events.order(:updated_at).where(type: ['MatchEvents::DecisionAction', 'MatchEvents::Note']).each do |event|
              steps[decision_order] ||= []
              case event.type
              when 'MatchEvents::DecisionAction'
                steps[decision_order] << [event.updated_at.to_date, "Note: #{event.note}"] if event.note.present?
                case event.action
                when 'back'
                  steps[decision_order] << [event.updated_at.to_date, "Step rewound"]
                  decision_order -= 1
                when 'accepted'
                  steps[decision_order] << [event.updated_at.to_date, "Step completed"]
                  decision_order += 1
                end
              when 'MatchEvents::Note'
                steps[decision_order] << [event.updated_at.to_date, "Note: #{event.note}"]
              end
            end
            steps
          end
        ]
      end.to_h
    end
    helper_method :actions

    def clients(sub_program_id)
      Client.
        visible_by(current_user).
        joins(client_opportunity_matches: :opportunity).
        merge(Opportunity.joins(:voucher).
          merge(Voucher.where(sub_program_id: sub_program_id))).
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

    def report_params
      opts = params.require(:match_progress).
        permit(
          sub_programs: [],
        )
      opts[:sub_programs] = opts[:sub_programs].reject(&:blank?).map(&:to_i)
      opts
    end

    def report_source
      Warehouse::CasReport
    end
  end
end
