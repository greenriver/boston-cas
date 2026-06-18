###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Warehouse
  class Tagging < Base
    # Ignore the STI bits
    self.inheritance_column = nil
    belongs_to :file, -> { where(taggable_type: 'GrdaWarehouse::File') }, primary_key: :id, foreign_key: :taggable_id
    belongs_to :tag
  end
end
