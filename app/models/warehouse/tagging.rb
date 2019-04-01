module Warehouse
  class Tagging < Base
    # Ignore the STI bits
    self.inheritance_column = nil
    belongs_to :file, -> { where(taggable_type: 'GrdaWarehouse::File') }, primary_key: :id, foreign_key: :taggable_id
  end
end
