###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProgramContact < ApplicationRecord
  belongs_to :program, required: :true, inverse_of: :program_contacts
  belongs_to :contact, required: :true, inverse_of: :program_contacts
end
