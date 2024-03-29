###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module NonHmisClientsHelper
  PHONE_NUMBER_REGEX = /(?<!\d)\(?[\d]{3}\)?[\s|-]?[\d]{3}-?[\d]{4}(?!\d)/

  def client_type
    controller_name.gsub('_clients', '')
  end

  def client_identified?
    client_type == 'identified'
  end

  def client_imported?
    client_type == 'imported'
  end

  def assessment_is_pathways?
    @assessment.type.include? 'Pathways'
  end

  def pathways_enabled?
    Config.get("#{client_type}_client_assessment").include? 'Pathways' rescue false # rubocop:disable Style/RescueModifier
  end

  def latest_assessment_for_client?
    @non_hmis_client.current_assessment == @assessment
  end
end
