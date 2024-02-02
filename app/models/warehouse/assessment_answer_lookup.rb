###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class AssessmentAnswerLookup < Base
    self.inheritance_column = :_disabled

    scope :for_column, ->(column) do
      where(assessment_question: column)
    end
  end
end
