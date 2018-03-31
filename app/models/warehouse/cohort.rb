module Warehouse
  class Cohort < Base
    scope :active, -> do
      where(active_cohort: true)
    end

  end
end