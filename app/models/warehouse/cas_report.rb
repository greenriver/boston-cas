# for writing latest state of matches X decisions into HMIS database
module Warehouse
  class CasReport < Base
    self.table_name = 'cas_reports'
  end
end