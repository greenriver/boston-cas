###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module NonHmisClientsHelper

  def client_type
    controller_name.gsub('_clients', '')
  end

  def client_identified?
    client_type == 'identified'
  end

  def assessment_is_pathways?
    @assessment.type.include? 'Pathways'
  end

  def pathways_enabled?
    Config.get("#{client_type}_client_assessment").include? 'Pathways' rescue false
  end

  def latest_assessment_for_client?
    @non_hmis_client.current_assessment == @assessment
  end

end
