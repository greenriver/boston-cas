###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ReportsController < ApplicationController
  before_action :require_can_view_reports!

  def index
    @report_definitions = ReportDefinition.enabled.
      ordered.
      group_by(&:report_group)
    end
end
