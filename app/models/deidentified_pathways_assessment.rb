###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class DeidentifiedPathwaysAssessment < DeidentifiedClientAssessment
  include PathwaysCalculations

  def default?
    false
  end
end