module Warehouse
  class Cohort < Base
    scope :active, -> do
      where(active_cohort: true, deleted_at: nil)
    end
  end
end