###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class CreateThemes < ActiveRecord::Migration[7.2]
  def change
    create_table :themes do |t|
      t.string :client
      t.text :homepage_content
      t.text :css

      t.timestamps
    end
  end
end
