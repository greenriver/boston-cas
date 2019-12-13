###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class IdentifiedClientAssessment < NonHmisAssessment
  def self.assessments
    {
      'Default Assessment' => 'IdentifiedClientAssessment',
      'Pathways Assessment' => 'IdentifiedPathwaysAssessment',
    }
  end
end