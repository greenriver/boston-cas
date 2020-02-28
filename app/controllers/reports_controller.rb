###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ReportsController < ApplicationController
  def index
    @report_definitions = ReportDefinition.enabled.
      ordered.
      group_by(&:report_group)
    end
end