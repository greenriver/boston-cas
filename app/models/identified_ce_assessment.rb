###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class IdentifiedCeAssessment < IdentifiedClientAssessment
  def title
    Translation.translate('CE Assessment')
  end

  def for_matching
    {
      'IdentifiedCeAssessment' => title,
    }
  end
end
