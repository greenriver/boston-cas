###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ReportDefinition < ApplicationRecord
  scope :enabled, -> do
    where(enabled: true)
  end

  scope :ordered, -> do
    order(weight: :asc, name: :asc)
  end
end