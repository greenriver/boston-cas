###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Warehouse
  class Tagging < Base
    # Ignore the STI bits
    self.inheritance_column = nil
    belongs_to :file, -> { where(taggable_type: 'GrdaWarehouse::File') }, primary_key: :id, foreign_key: :taggable_id
  end
end