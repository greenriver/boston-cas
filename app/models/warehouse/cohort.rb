###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class Cohort < Base
    scope :active, -> do
      where(active_cohort: true, deleted_at: nil)
    end

    scope :visible_in_cas, -> do
      where(visible_in_cas: true)
    end
  end
end
