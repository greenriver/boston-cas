###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ProgramService < ApplicationRecord
  belongs_to :program, inverse_of: :program_services
  belongs_to :service, inverse_of: :program_services
end
