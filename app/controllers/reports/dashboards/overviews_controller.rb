###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
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
    section = sections.detect { |name| @report.section_name(params[:section]).to_sym == name }
    data = @report.public_send(section)
    @section = @report.human_readable_section_name(section)

    if params[:section].downcase == 'unsuccessful' && params[:reason].present?
      data = data.has_reason(params[:reason])
      @reason = @report.reason_from_param(params[:reason])
    end
    data = data.current_step.joins(:client).current_step.order(updated_at: :desc)
    @pagy, @data = pagy(data.current_step.joins(:client).order(updated_at: :desc), items: 50)
  end

  def sections
    @report.section_ids
  end

  def details_params
    @filter.for_params
  end
  helper_method :details_params

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
