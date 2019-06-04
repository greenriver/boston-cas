###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

# for writing latest state of matches X decisions into HMIS database
module Warehouse
  class CasReport < Base
    self.table_name = 'cas_reports'
  end
end