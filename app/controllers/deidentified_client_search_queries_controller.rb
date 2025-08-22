###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class DeidentifiedClientSearchQueriesController < DeidentifiedClientsController
  skip_before_action :load_client

  def show
    @search_query = ClientSearchQuery.find(params[:id])

    # If there's a new search query in params, handle it
    if params[:search_form].present? && params[:search_form][:q].present? && params[:search_form][:q] != @search_query.query_params[:q]
      handle_search_query
      return if performed? # Stop if we redirected
    end

    # sort
    sort_order = sorter
    @sorted_by = sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first&.try(:[], :title)

    # Use the saved search query parameters
    params[:search_form] = @search_query.query_params
    @search = search_setup(scope: :text_search)
    @non_hmis_clients = @search

    # filter
    @non_hmis_clients = @non_hmis_clients.where(agency: Agency.where(name: clean_agency)) if clean_agency.present?
    @non_hmis_clients = @non_hmis_clients.where('active_cohort_ids @> ?', clean_cohort) if clean_cohort.present?
    @non_hmis_clients = @non_hmis_clients.where(available: clean_available) unless clean_available.nil?
    @non_hmis_clients = @non_hmis_clients.family_member(clean_family_member) unless clean_family_member.nil?
    @non_hmis_clients = @non_hmis_clients.joins(:non_hmis_assessments).merge(NonHmisAssessment.where(type: clean_assessment)) if clean_assessment.present?

    respond_to do |format|
      format.html do
        # paginate
        @page = params[:page].presence || 1
        @non_hmis_clients = @non_hmis_clients.joins(:agency) if @column == 'agencies.name'
        @non_hmis_clients = @non_hmis_clients.reorder(sort_order).page(@page.to_i).per(25)
        render template: 'deidentified_clients/index'
      end
      format.xlsx do
        download
      end
    end
  end

  private

  def client_type
    'deidentified'
  end
  helper_method :client_type
end
