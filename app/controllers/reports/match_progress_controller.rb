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
          headers['Content-Disposition'] = "attachment; filename=#{filename}"
        end
      end
    end

    def actions(sub_program)
      # {client_id => {decision_order => [[date, text], ...]}}
      {}
    end
    helper_method :actions

    def clients(sub_program)
      report_source.
        for_sub_program(program_name: sub_program.first, sub_program_name: sub_program.last).
        joins(:client).
        distinct.
        order(:LastName, :FirstName).
        pluck(:match_id, :FirstName, :LastName).
        map do |id, first_name, last_name|
        [id, "#{last_name}, #{first_name}"]
      end.to_h
    end
    helper_method :clients

    def step_names(sub_program)
      report_source.
        for_sub_program(program_name: sub_program.first, sub_program_name: sub_program.last).
        order(decision_order: :asc).
        distinct.
        pluck(:decision_order, :match_step).
        to_h
    end
    helper_method :step_names

    def sub_programs
      @sub_programs ||= report_source.
        order(:program_name, :sub_program_name).
        distinct.
        pluck(:program_name, :sub_program_name)
    end
    helper_method :sub_programs

    def sub_program_list
      @sub_program_list ||= begin
        sub_programs.map.with_index do |name, index|
          [
            name.join('|'),
            index,
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
