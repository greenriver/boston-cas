###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ReportDefinition < ApplicationRecord
  scope :enabled, -> do
    where(enabled: true)
  end

  scope :ordered, -> do
    order(weight: :asc, name: :asc)
  end
end
