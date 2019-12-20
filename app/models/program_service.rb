###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProgramService < ApplicationRecord
  belongs_to :program, inverse_of: :program_services
  belongs_to :service, inverse_of: :program_services
end