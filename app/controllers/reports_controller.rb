###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ReportsController < ApplicationController
  before_action :require_can_view_reports!

  def index
    @report_definitions = ReportDefinition.enabled.
      ordered.
      group_by(&:report_group)
    end
end