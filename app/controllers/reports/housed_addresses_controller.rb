###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/production/LICENSE.md
###

module Reports
  class HousedAddressesController < ApplicationController
    include ArelHelper

    before_action :authenticate_user!

    def index
      @filter = filter
      @addresses = addresses(filter.start, filter.end)

      @addresses = @addresses.page(params[:page]).per(25)
    end

    def headers
      report_schema.keys
    end
    helper_method :headers

    def columns
      report_schema.values
    end
    helper_method :columns

    private def filter
      return OpenStruct.new(start: 6.months.ago, end: 1.days.ago) unless params[:filter].present?

      OpenStruct.new(start: filter_params[:start].to_date, end: filter_params[:end].to_date)
    end

    private def filter_params
      params.require(:filter).permit(
        :start,
        :end,
      )
    end

    private def report_schema
      @report_schema ||= {
        'Program Name' => p_t[:name],
        'Sub-Program' => sp_t[:name],
        'First Name' => c_t[:first_name],
        'Last Name' => c_t[:last_name],
        'Housing Address' => md_b_t[:address],
        'Padmission?' => md_b_t[:external_software_used],
        'Date Housed' => md_b_t[:client_move_in_date],
      }.freeze
    end

    private def addresses(start_date, end_date)
      ClientOpportunityMatch.
        joins(:program, :sub_program, :client, :decisions).
        where(match_decisions: { client_move_in_date: start_date .. end_date }).
        where(closed_reason: :success)
    end
  end
end
