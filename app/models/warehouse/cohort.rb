module Warehouse
  class Cohort < Base
    scope :active, lambda {
      where(active_cohort: true, deleted_at: nil)
    }

    scope :visible_in_cas, lambda {
      where(visible_in_cas: true)
    }
  end
end
