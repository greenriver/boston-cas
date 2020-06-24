###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ProgramService < ApplicationRecord
  belongs_to :program, inverse_of: :program_services
  belongs_to :service, inverse_of: :program_services
end