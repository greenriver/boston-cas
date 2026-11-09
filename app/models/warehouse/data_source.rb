###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Warehouse
  class DataSource < Base
    self.table_name = :data_sources

    has_many :projects, class_name: 'Warehouse::Project', inverse_of: :data_source

    def short_display_name
      short_name.presence || name
    end
  end
end
