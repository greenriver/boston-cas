###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Warehouse
  class Cohort < Base
    self.inheritance_column = :_disabled
    acts_as_paranoid

    scope :active, -> do
      where(active_cohort: true, deleted_at: nil)
    end

    scope :visible_in_cas, -> do
      where(visible_in_cas: true)
    end
  end
end
