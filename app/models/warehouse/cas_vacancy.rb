module Warehouse
  class CasVacancy < Base
    belongs_to :program
    belongs_to :sub_program
  end
end