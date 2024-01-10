###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class DeidentifiedPathwaysVersionFour < DeidentifiedClientAssessment
  include PathwaysVersionFourCalculations

  def self.client_table_headers(user)
    columns = [
      'Client Identifier',
      'Agency',
    ]
    columns << 'Assessment Score' if user.can_manage_deidentified_clients?
    columns << 'Assessment Date'
    columns << 'Days Homeless in the Last 3 Years'
    columns << 'Status'
    columns << 'CAS Client' if user.can_view_some_clients?
    columns << '' if user.can_manage_deidentified_clients?
    columns
  end

  def self.client_table_row(client, user)
    url_helpers = Rails.application.routes.url_helpers
    view_helper = ActionController::Base.helpers
    current_assessment = client.current_assessment
    row = [
      view_helper.link_to(client.client_identifier, url_helpers.deidentified_client_path(id: client.id)),
      client.agency&.name,
    ]
    score = current_assessment&.assessment_score
    assessment_title = view_helper.content_tag(:em, current_assessment&.title)
    assessment_title = view_helper.content_tag(:div, assessment_title, class: 'mt-2')
    assessment_date = view_helper.content_tag(:span, client&.assessed_at&.to_date.to_s)
    assessment_date = view_helper.content_tag(:span) do
      view_helper.concat(assessment_date)
      view_helper.concat(assessment_title)
    end
    client_link = if client.client
      view_helper.link_to(url_helpers.client_path(client.client), class: 'btn btn-secondary btn-sm d-inline-flex align-items-center') do
        view_helper.concat 'View'
        view_helper.concat view_helper.content_tag(:span, nil, class: 'icon-arrow-right2 ml-2')
      end
    end
    delete_link = if client.involved_in_match?
      view_helper.link_to(url_helpers.deidentified_client_path(client), method: :delete, data: { confirm: 'Would you really like to delete this Non-HMIS client?' }, class: ['btn', 'btn-sm', 'btn-danger']) do
        view_helper.concat(view_helper.content_tag(:span, nil, class: 'icon-cross'))
        view_helper.concat(view_helper.content_tag(:span, 'Delete'))
      end
    end
    row << score if user.can_manage_deidentified_clients?
    row << assessment_date
    row << current_assessment&.days_homeless_in_the_last_three_years
    row << if client.available then 'Available' else 'Ineligible' end
    row << client_link if user.can_view_some_clients?
    row << delete_link if user.can_manage_deidentified_clients?

    row
  end

  def default?
    false
  end

  def assessment_params(params)
    params.require(:deidentified_pathways_version_four).
      permit(non_hmis_assessment_params)
  end
end
