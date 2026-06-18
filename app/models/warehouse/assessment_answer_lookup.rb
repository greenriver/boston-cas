###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module Warehouse
  class AssessmentAnswerLookup < Base
    self.inheritance_column = :_disabled

    scope :for_column, ->(column) do
      where(assessment_question: column)
    end
  end
end
