###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Warehouse
  class Organization < Base
    self.table_name = :Organization
    acts_as_paranoid(column: :DateDeleted)

    has_many :projects, primary_key: [:OrganizationID, :data_source_id], foreign_key: [:OrganizationID, :data_source_id], inverse_of: :organization
  end
end
