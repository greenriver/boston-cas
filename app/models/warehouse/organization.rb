# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class Organization < Base
    self.table_name = :Organization
    acts_as_paranoid(column: :DateDeleted)

    has_many :projects, primary_key: [:OrganizationID, :data_source_id], query_constraints: [:OrganizationID, :data_source_id], inverse_of: :organization
  end
end
