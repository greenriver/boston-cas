###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class ProgramsToProjects < Base
    self.table_name = :cas_programs_to_projects

    belongs_to :program
    belongs_to :project
  end
end