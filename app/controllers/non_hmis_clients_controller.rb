###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'xlsxtream'
class NonHmisClientsController < ApplicationController
  include AjaxModalRails::Controller
  include MatchShow
  before_action :load_client, only: [:show, :edit, :update, :new_assessment, :destroy, :shelter_location]
  before_action :require_can_edit_this_client!, only: [:edit, :update, :new_assessment, :destroy]
  before_action :load_neighborhoods
  before_action :load_contacts, only: [:new, :edit]
  before_action :set_active_filter, only: [:index]
  before_action :find_match, only: [:current_assessment_limited]

  def index
    # sort
    sort_order = sorter
    @sorted_by = sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first&.try(:[], :title)

    # construct query
    @q = client_source.ransack(params[:q])
    @non_hmis_clients = @q.result(distinct: false)

    # filter
    @non_hmis_clients = @non_hmis_clients.where(agency: Agency.where(name: clean_agency)) if clean_agency.present?

    @non_hmis_clients = @non_hmis_clients.where('active_cohort_ids @> ?', clean_cohort) if clean_cohort.present?

    @non_hmis_clients = @non_hmis_clients.where(available: clean_available) unless clean_available.nil?

    @non_hmis_clients = @non_hmis_clients.family_member(clean_family_member) unless clean_family_member.nil?

    respond_to do |format|
      format.html do
        # paginate
        @page = params[:page].presence || 1
        @non_hmis_clients = @non_hmis_clients.joins(:agency) if @column == 'agencies.name'
        @non_hmis_clients = @non_hmis_clients.reorder(sort_order).page(@page.to_i).per(25)
      end
      format.xlsx do
        download
      end
    end
  end

  def download
    io = StringIO.new
    xlsx = Xlsxtream::Workbook.new(io)
    xlsx.write_worksheet client_type do |sheet|
      sheet << client_source.new.download_headers
      seen = Set.new
      download_clients.each do |client|
        next if seen.include?(client.id)

        sheet << client.download_data
        seen << client.id
      end
    end
    xlsx.close
    send_data(
      io.string,
      filename: "#{client_type}.xlsx",
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    )
  end

  def current_assessment_limited
    @modal_size = :lg
    @assessment = NonHmisAssessment.where(type: assessment_type).find(params[:id].to_i)
    @non_hmis_client = @assessment.non_hmis_client
  end

  private def download_clients
    return @non_hmis_clients.order(updated_at: :desc) unless pathways_enabled?

    @non_hmis_clients.joins(:non_hmis_assessments).merge(NonHmisAssessment.where(type: assessment_type).order(entry_date: :desc))
  end

  def new
    @non_hmis_client = client_source.new(agency_id: current_user.agency&.id)
    @contact_id = current_user.contact.id
  end

  def show
    @shelter_names = ShelterHistory.shelter_locations
    @assessments = @non_hmis_client.non_hmis_assessments.order(entry_date: :desc, created_at: :desc)
    if params[:assessment_id] && pathways_enabled?
      render :assessment
    end
  end

  def edit
    @contact_id = @non_hmis_client.contact_id
  end

  def shelter_location
    if shelter_location_params[:shelter_name].present?
      @non_hmis_client.update(shelter_location_params)
      @non_hmis_client.current_assessment&.update(shelter_location_params)
      @non_hmis_client.shelter_histories.create(shelter_location_params.merge(user_id: current_user.id))
    end
    respond_with(@non_hmis_client, location: path_for_non_hmis_client)
  end

  private def add_shelter_history(opts)
    shelter_opts = opts.slice('shelter_name')
    return unless shelter_opts[:shelter_name].present?

    @non_hmis_client.assign_attributes(shelter_opts)
    @non_hmis_client.shelter_histories.create({ shelter_name: @non_hmis_client.shelter_name, user_id: current_user.id }) if @non_hmis_client.attribute_changed?(:shelter_name)
  end

  def sorter
    @column = params[:sort]
    @direction = params[:direction]

    if @column.blank?
      if pathways_enabled?
        if can_manage_identified_clients?
          @column = 'assessment_score'
          @direction = 'desc'
        else
          @column = 'assessed_at'
          @direction = 'asc'
        end
      else
        @column = 'days_homeless_in_the_last_three_years'
        @direction = 'desc'
      end
      sort_string = "#{@column} #{@direction}"
    else
      sort_string = sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.first[:order]
    end

    sort_string += ' NULLS LAST' if ApplicationRecord.connection.adapter_name == 'PostgreSQL'

    sort_string
  end

  def load_client
    @non_hmis_client = client_source.find(params[:id].to_i)
    @assessment = load_assessment || @non_hmis_client.current_assessment
  rescue Exception
    client = NonHmisClient.find params[:id].to_i
    redirect_to polymorphic_path([action_name.to_sym, :imported_client], id: params[:id]) if client.type == 'ImportedClient'
  end

  def load_assessment
    NonHmisAssessment.find(params[:assessment_id].to_i) if params[:assessment_id]
  end

  def load_neighborhoods
    @neighborhoods = Neighborhood.order(:name).pluck(:id, :name)
  end

  def load_contacts
    @contacts = {}
    user_scope = User.active.joins(:contact).order(:email)
    unless can_edit_all_clients?
      if current_user.agency.present?
        user_scope = user_scope.where(agency_id: current_user.agency.id)
      else
        # if the current user doesn't have an agency, they can only assign this client to themselves
        user_scope = user_scope.where(id: current_user.id)
      end
    end
    user_scope.each do |user|
      agency_name = user.agency&.name || 'Unknown'
      @contacts[agency_name] ||= []
      @contacts[agency_name] << [ "#{user.first_name} #{user.last_name} | #{user.email}", user.contact&.id ]
    end
  end

  def agency_id_for_contact(contact_id)
    return unless contact_id.present?

    contact = Contact.find(contact_id.to_i)
    contact.user&.agency_id
  end

  def set_active_filter
    @active_filter = filter_terms.map { |k| params[k].present? }.any?
  end

  def clean_agency
    NonHmisClient.possible_agencies.
      detect { |m| m.downcase == params[:agency]&.downcase }
  end

  def clean_cohort
    return nil unless Warehouse::Base.enabled?

    NonHmisClient.possible_cohorts.keys.detect{|m| m.to_i == params[:cohort]&.to_i}.to_s
  end

  def clean_available
    [true, false].detect{|m| m.to_s == params[:available]}
  end

  def clean_family_member
    [true, false].detect{|m| m.to_s == params[:family_member]}
  end

  def clean_client_params(dirty_params)
    dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
    dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?

    if can_edit_all_clients?
      contact_agency_id = agency_id_for_contact(dirty_params[:contact_id])
      dirty_params[:agency_id] = contact_agency_id if contact_agency_id.present?
    else
      dirty_params[:agency_id] = current_user.agency_id
    end

    dirty_params[:available] = dirty_params[:available] == '1' || dirty_params[:available] == 'true' if dirty_params[:available].present?
    dirty_params[:shelter_name] = dirty_params.dig(:client_assessments_attributes, '0', :shelter_name)

    return dirty_params
  end

  private def pathways_enabled?
    assessment_type&.include?('Pathways')
  end

  private def find_match
    return if can_view_all_covid_pathways?

    @match = ClientOpportunityMatch.find(params[:match_id].to_i)
  end

  private def require_can_edit_this_client!
    not_authorized! unless @non_hmis_client.editable_by?(current_user)
  end

  private def shelter_location_params
    params.require(:non_hmis_client).permit(
      :shelter_name,
    )
  end
end
