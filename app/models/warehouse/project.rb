module Warehouse
  class Project < Base
    self.table_name = :Project

    belongs_to :organization, class_name: Warehouse::Organization.name, primary_key: [:OrganizationID, :data_source_id], foreign_key: [:OrganizationID, :data_source_id], inverse_of: :projects
  end
end
