module Warehouse
  class Tag < Base
    scope :available, -> { all }
  end
end
