###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Reports::Dashboards::ContactsController < ApplicationController
  before_action :require_can_view_reports!
  before_action :set_filter
  before_action :set_report

  def index
    @details_url = details_reports_dashboards_contacts_path(details_params)
  end

  def details
    column = params[:column]
    route = params[:route_id]
    data = @report.route_data(route)
    @route = data[:route]
    @column = @report.human_readable_column_name(column)

    column_data = data[column.to_sym].joins(:client)
    @pagy, @data = pagy(column_data, items: 50)
  end

  def details_params
    @filter.for_params
  end
  helper_method :details_params

  def filter_params
    return {} unless params[:filters].present?

    params.require(:filters).permit(@filter.known_params)
  end

  def sections
    @report.section_ids
  end

  def set_filter
    @filter = Reporting::FilterBase.new(
      default_start: Date.current.last_year,
      default_end: Date.current,
    )
    @filter.update(filter_params)
  end

  def set_report
    @report = dashboard_source.new(@filter)
  end

  def dashboard_source
    Dashboards::Contacts
  end
end
