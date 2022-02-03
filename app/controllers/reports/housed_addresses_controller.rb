###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###


module Reports
  class HousedAddressesController < ApplicationController
    include ArelHelper

    before_action :authenticate_user!

    def index
      @filter = filter
      @addresses = addresses(filter.start, filter.end)

      respond_to do |format|
        format.html do
          @addresses = @addresses.page(params[:page]).per(25)
        end
        format.xlsx do
          filename = 'Housed Client Addresses.xlsx'
          render xlsx: 'index.xlsx', filename: filename
        end
      end
    end

    def header
      @header ||= report_schema.keys
    end
    helper_method :header

    def data
      @addresses.pluck(columns)
    end
    helper_method :data

    def columns
      @columns ||= report_schema.values.map { |descriptor| descriptor[:query] }
    end

    def column_types
      @column_types ||= report_schema.values.map { |descriptor| descriptor[:display_type] }
    end
    helper_method :column_types

    private def filter
      return default_filter unless params[:filter].present?

      OpenStruct.new(start: filter_params[:start].to_date, end: filter_params[:end].to_date)
    end

    private def default_filter
      OpenStruct.new(start: 6.months.ago, end: 1.days.ago)
    end

    private def filter_params
      return default_filter.to_h unless params[:filter].present?

      params.require(:filter).permit(
        :start,
        :end,
      )
    end
    helper_method :filter_params

    private def report_schema
      @report_schema ||= {
        'Program Name' => { query: p_t[:name], display_type: :text },
        'Sub-Program' => { query: sp_t[:name], display_type: :text },
        'First Name' => { query: c_t[:first_name], display_type: :text },
        'Last Name' => { query: c_t[:last_name], display_type: :text },
        'Housing Address' => { query: md_b_t[:address], display_type: :address },
        _('Did you or this client use external software to help with housing?') => { query: md_b_t[:external_software_used], display_type: :boolean },
        'Date Housed' => { query: md_b_t[:client_move_in_date], display_type: :text },
        'Match ID' => { query: com_t[:id], display_type: :integer },
      }.freeze
    end

    private def addresses(start_date, end_date)
      ClientOpportunityMatch.
        joins(:program, :sub_program, :client, :decisions).
        where(md_b_t[:client_move_in_date].between(start_date .. end_date).and(md_b_t[:client_move_in_date].not_eq(nil))).
        where(closed_reason: :success).
        order(md_b_t[:client_move_in_date].desc)
    end
  end
end
