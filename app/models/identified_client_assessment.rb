###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedClientAssessment < NonHmisAssessment
  def self.assessments
    {
      'Default Assessment' => 'IdentifiedClientAssessment',
      'Pathways Assessment' => 'IdentifiedPathwaysAssessment',
      'COVID Pathways Assessment' => 'IdentifiedCovidPathwaysAssessment',
    }
  end

  def editable_by?(user)
    return true if user.can_manage_identified_clients?
    return false unless user.can_enter_identified_clients?

    agency_id == user.agency_id
  end

  def viewable_by?(user)
    if non_hmis_client.pathways_enabled?
      user.can_manage_identified_clients? || user.can_enter_identified_clients?
    else
      editable_by?(user)
    end
  end
end
