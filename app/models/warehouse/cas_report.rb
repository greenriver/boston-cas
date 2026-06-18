###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# for writing latest state of matches X decisions into HMIS database
module Warehouse
  class CasReport < Base
    self.table_name = 'cas_reports'
  end
end
