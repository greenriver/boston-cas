class ProgramService < ActiveRecord::Base
  belongs_to :program, required: :true, inverse_of: :program_services
  belongs_to :service, required: :true, inverse_of: :program_services
end
