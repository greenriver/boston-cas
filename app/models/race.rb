###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Race < ApplicationRecord
  self.table_name = "primary_races"

  has_many :clients, primary_key: :numeric, foreign_key: :race_id
end
