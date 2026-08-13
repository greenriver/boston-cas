###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Warehouse
  class Organization < Base
    self.table_name = :Organization
    acts_as_paranoid(column: :DateDeleted)

    has_many :projects, primary_key: [:OrganizationID, :data_source_id], foreign_key: [:OrganizationID, :data_source_id], inverse_of: :organization
  end
end
