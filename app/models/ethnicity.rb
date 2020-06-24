###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Ethnicity < ApplicationRecord
  has_many :clients, primary_key: :numeric, foreign_key: :ethnicity_id
end
