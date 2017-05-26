# for writing latest state of matches X decisions into HMIS database
module Hmis
  class Report < Base
    self.table_name = 'cas_reports'
  end
end