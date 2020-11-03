###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedClientAssessment < NonHmisAssessment
  def self.assessments
    {
      'Default Assessment' => 'DeidentifiedClientAssessment',
      'Pathways Assessment' => 'DeidentifiedPathwaysAssessment',
      'COVID Pathways Assessment' => 'DeidentifiedCovidPathwaysAssessment',
    }
  end
end
