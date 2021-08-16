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

  def self.client_table_headers(user)
    columns = [
      'Last Name',
      'First Name',
      'Agency',
      'Assessment Score',
      'Cohorts',
      'Days Homeless in the Last 3 Years',
      'Available?',
    ]
    columns << '' if user.can_manage_identified_clients?
    columns << 'CAS Client' if user.can_view_some_clients?
    columns
  end

  def self.client_table_row(client, user)
    url_helpers = Rails.application.routes.url_helpers
    view_helper = ActionController::Base.helpers
    current_assessment = client.current_assessment
    row = [
      view_helper.link_to(client.last_name, url_helpers.identified_client_path(id: client.id)),
      view_helper.link_to(client.first_name, url_helpers.identified_client_path(id: client.id)),
      client.agency&.name,
      current_assessment.assessment_score,
      simple_format(client.cohort_names, {}, sanitize: false),
      current_assessment.days_homeless_in_the_last_three_years,
      checkmark(client.available?),
    ]

    client_link = view_helper.link_to(url_helpers.client_path(client.client), class: 'btn btn-secondary btn-sm d-inline-flex align-items-center') do
      view_helper.concat 'View'
      view_helper.concat view_helper.content_tag(:span, nil, class: 'icon-arrow-right2 ml-2')
    end
    delete_link = view_helper.link_to(url_helpers.identified_client_path(client), method: :delete, data: { confirm: 'Would you really like to delete this Non-HMIS client?' }, class: ['btn', 'btn-sm', 'btn-danger']) do
      view_helper.concat(view_helper.content_tag(:span, nil, class: 'icon-cross'))
      view_helper.concat(view_helper.content_tag(:span, 'Delete'))
    end
    row << client_link if user.can_view_some_clients? && client.client
    row << delete_link if user.can_manage_identified_clients? && ! client.involved_in_match?

    row
  end
end
