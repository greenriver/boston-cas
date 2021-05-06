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

  def editable_by?(user)
    return true if user.can_manage_deidentified_clients?
    return false unless user.can_enter_deidentified_clients?

    agency_id == user.agency_id
  end

  def viewable_by?(user)
    if non_hmis_client.pathways_enabled?
      user.can_manage_deidentified_clients? || user.can_enter_deidentified_clients?
    else
      editable_by?(user)
    end
  end
end
