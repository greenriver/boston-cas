###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedCeAssessment < IdentifiedClientAssessment
  def title
    _('CE Assessment')
  end

  def for_matching
    {
      'IdentifiedCeAssessment' => title,
    }
  end
end
