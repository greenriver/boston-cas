###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProgramService < ActiveRecord::Base
  belongs_to :program, required: :true, inverse_of: :program_services
  belongs_to :service, required: :true, inverse_of: :program_services
end