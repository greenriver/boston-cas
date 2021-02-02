###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class File < Base
    # Ignore the STI bits
    self.inheritance_column = nil
    has_many :taggings, primary_key: :id, foreign_key: :taggable_id
    scope :for_client, -> (warehouse_client_id) do
      where(
        type: 'GrdaWarehouse::ClientFile',
        visible_in_window: true,
        client_id: warehouse_client_id
      )
    end
  end
end
