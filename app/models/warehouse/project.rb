###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class Project < Base
    self.table_name = :Project

    belongs_to :organization, class_name: Warehouse::Organization.name, primary_key: [:OrganizationID, :data_source_id], foreign_key: [:OrganizationID, :data_source_id], inverse_of: :projects

    def name
      return 'Confidential Project' if confidential?

      self.ProjectName
    end

    def self.options_for_select
      options = {}
      where(confidential: false).
        joins(:organization).
        preload(:organization).
        order(OrganizationName: :asc, ProjectName: :asc).
        each do |project|
          org_name = project.organization.OrganizationName
          options[org_name] ||= []
          options[org_name] << [
            project.ProjectName,
            project.id,
          ]
        end
      options
    end
  end
end
