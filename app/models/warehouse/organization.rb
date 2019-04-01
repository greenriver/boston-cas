module Warehouse
  class Organization < Base
    self.table_name = :Organization

    has_many :projects, primary_key: [:OrganizationID, :data_source_id], foreign_key: [:OrganizationID, :data_source_id], inverse_of: :organization
  end
end
