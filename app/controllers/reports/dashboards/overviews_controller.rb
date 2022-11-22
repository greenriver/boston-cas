###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Reports::Dashboards::OverviewsController < ApplicationController
  before_action :require_can_view_reports!
  before_action :set_filter
  before_action :set_report

  def index
    @details_url = details_reports_dashboards_overviews_path(details_params)
  end

  def details
    @section = sections.detect { |name| @report.section_name(params[:section]).to_sym == name }
    data = @report.public_send(@section)
    return dashboard_source.none if data.blank?

    @reason = params[:reason]
    data = data.has_reason(@reason) if @reason.present?

    data = data.current_step.joins(:client)

    @data = data.current_step.order(updated_at: :desc)
  end

  def sections
    @report.section_ids
  end

  def details_params
    @filter.for_params
  end
  helper_method :details_params

  def details_columns
    [
      :terminal_status,
      :updated_at,
      :program_name,
      :sub_program_name,
    ]
  end
  helper_method :details_columns

  def filter_params
    return {} unless params[:filters].present?

    params.require(:filters).permit(@filter.known_params)
  end

  def set_filter
    @filter = Reporting::FilterBase.new(
      default_start: Date.current.last_year,
      default_end: Date.current,
      match_routes: Reporting::FilterBase.new.match_route_options_for_select.values.first,
    )
    @filter.update(filter_params)
  end

  def set_report
    @report = dashboard_source.new(@filter)
  end

  def dashboard_source
    Dashboards::Overview
  end
end
