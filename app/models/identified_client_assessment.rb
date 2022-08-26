###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedClientAssessment < NonHmisAssessment
  def self.assessments
    {
      'Default Assessment' => 'IdentifiedClientAssessment',
      'Pathways Assessment' => 'IdentifiedPathwaysAssessment',
      'COVID Pathways Assessment' => 'IdentifiedCovidPathwaysAssessment',
      'Pathways V3' => 'IdentifiedPathwaysVersionThree',
      'TC HAT' => 'IdentifiedTcHat',
      'CE Assessment' => 'IdentifiedCeAssessment',
    }
  end

  def for_matching
    {
      'IdentifiedClientAssessment' => 'Non-HMIS Assessment - Identified',
    }
  end

  def identified?
    true
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

  def unlockable_by?(user)
    user.can_manage_identified_clients?
  end

  def self.client_table_headers(user)
    columns = [
      'Last Name',
      'First Name',
      'Agency',
      'Assessment Score',
      'Assessment Date',
      'Cohorts',
      'Days Homeless in the Last 3 Years',
      'Available?',
    ]
    columns << 'CAS Client' if user.can_view_some_clients?
    columns << '' if user.can_manage_identified_clients?
    columns
  end

  def self.client_table_row(client, user)
    url_helpers = Rails.application.routes.url_helpers
    view_helper = ActionController::Base.helpers
    current_assessment = client.current_assessment
    assessment_title = view_helper.content_tag(:em, current_assessment&.title)
    assessment_title = view_helper.content_tag(:div, assessment_title, class: 'mt-2')
    assessment_date = view_helper.content_tag(:span, client&.assessed_at&.to_date.to_s)
    assessment_date = view_helper.content_tag(:span) do
      view_helper.concat(assessment_date)
      view_helper.concat(assessment_title)
    end
    row = [
      view_helper.link_to(client.last_name, url_helpers.identified_client_path(id: client.id)),
      view_helper.link_to(client.first_name, url_helpers.identified_client_path(id: client.id)),
      client.agency&.name,
      current_assessment&.assessment_score,
      assessment_date,
      client.cohort_names.split("\n").join('<br />').html_safe,
      current_assessment&.days_homeless_in_the_last_three_years,
      checkmark(client.available?),
    ]

    client_link = if client.client
      view_helper.link_to(url_helpers.client_path(client.client), class: 'btn btn-secondary btn-sm d-inline-flex align-items-center') do
        view_helper.concat 'View'
        view_helper.concat view_helper.content_tag(:span, nil, class: 'icon-arrow-right2 ml-2')
      end
    end
    delete_link = if client.involved_in_match?
      view_helper.link_to(url_helpers.identified_client_path(client), method: :delete, data: { confirm: 'Would you really like to delete this Non-HMIS client?' }, class: ['btn', 'btn-sm', 'btn-danger']) do
        view_helper.concat(view_helper.content_tag(:span, nil, class: 'icon-cross'))
        view_helper.concat(view_helper.content_tag(:span, 'Delete'))
      end
    end
    row << client_link if user.can_view_some_clients?
    row << delete_link if user.can_manage_identified_clients?

    row
  end

  def assessment_params(params)
    params.require(:identified_client_assessment).
      permit(non_hmis_assessment_params)
  end
end
