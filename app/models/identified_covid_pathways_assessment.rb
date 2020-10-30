###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedCovidPathwaysAssessment < IdentifiedClientAssessment
  include CovidPathwaysCalculations

  def title
    'COVID Pathways'
  end

  def default?
    false
  end
end
