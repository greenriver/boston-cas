###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Reports::Dashboards::OverviewsController < ApplicationController
  include AjaxModalRails::Controller

  before_action :require_can_view_reports!
  before_action :set_filter
  before_action :set_report

  def index
  end

  def details
    @section = sections.detect { |name| params[:section].to_sym == name }
    data = @report.public_send(@section)
    return Client.none if data.nil?

    @key = data.keys.detect { |name| params[:key] == name } if params[:key].present?

    ids = if @key.present?
      @sub_key = data[@key].keys.detect { |name| params[:sub_key] == name } if params[:sub_key].present?
      if @sub_key.present?
        data[@key][@sub_key]
      else
        data[@key]
      end
    else
      data
    end

    @total_clients = ids.count
    @clients = Client.where(id: ids).
      visible_by(current_user).
      select(*details_columns)
  end

  def sections
    [
      :in_progress,
      :match_results,
      :match_results_by_quarter,
    ]
  end

  def details_params
    @filter.for_params
  end
  helper_method :details_params

  def details_columns
    [
      :id,
      :first_name,
      :last_name,
    ]
  end
  helper_method :details_columns

  def filter_params
    return {} unless params[:filters].present?

    params.require(:filters).permit(@filter.known_params)
  end

  def set_filter
    @filter = Reporting::FilterBase.new(default_start: Date.current.last_year, default_end: Date.current)
    @filter.update(filter_params)
  end

  def set_report
    @report = Dashboards::Overview.new(@filter)
  end
end
