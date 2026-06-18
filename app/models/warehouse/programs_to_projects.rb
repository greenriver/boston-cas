###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Warehouse
  class ProgramsToProjects < Base
    self.table_name = :cas_programs_to_projects

    belongs_to :program
    belongs_to :project
  end
end
