class ProgramContact < ActiveRecord::Base
  belongs_to :program, required: :true, inverse_of: :program_contacts
  belongs_to :contact, required: :true, inverse_of: :program_contacts
end