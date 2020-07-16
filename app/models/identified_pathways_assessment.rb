###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedPathwaysAssessment < IdentifiedClientAssessment
  include PathwaysCalculations

  def default?
    false
  end
end