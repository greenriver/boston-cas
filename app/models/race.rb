###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Race < ActiveRecord::Base
  self.table_name = "primary_races"

  has_many :clients, primary_key: :numeric, foreign_key: :race_id
end
