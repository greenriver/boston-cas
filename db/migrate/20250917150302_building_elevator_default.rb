###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class BuildingElevatorDefault < ActiveRecord::Migration[7.2]
  def change
    add_column :buildings, :elevator_accessible_default, :boolean, default: false
  end
end
