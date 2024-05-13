###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class File < Base
    # Ignore the STI bits
    self.inheritance_column = nil
    has_many :taggings, primary_key: :id, foreign_key: :taggable_id
    acts_as_paranoid

    scope :for_client, ->(warehouse_client_id) do
      where(
        type: 'GrdaWarehouse::ClientFile',
        visible_in_window: true,
        client_id: warehouse_client_id,
      )
    end

    def file_url
      Config.get(:warehouse_url) + "/clients/#{client_id}/files/#{id}"
    end
  end
end
