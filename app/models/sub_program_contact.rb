###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SubProgramContact < ApplicationRecord
  belongs_to :sub_program, inverse_of: :sub_program_contacts
  belongs_to :contact, inverse_of: :sub_program_contacts
end
