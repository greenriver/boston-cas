###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class AddReportingProjectIdToProgram < ActiveRecord::Migration[7.1]
  def change
    add_column :sub_programs, :reporting_project_id, :integer
  end
end
