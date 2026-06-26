###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class AddIncludeValueToHousingAttributes < ActiveRecord::Migration[7.2]
  def change
    add_column :housing_attributes, :include_value, :boolean, default: true, null: false
  end
end
