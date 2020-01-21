###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

require 'xlsxtream'
class NonHmisClientsController < ApplicationController
  before_action :load_client, only: [:show, :edit, :update, :new_assessment, :destroy]
  before_action :load_neighborhoods
  before_action :load_contacts, only: [:new, :edit]
  before_action :set_active_filter, only: [:index]

  helper_method :client_type

  def index

    # sort
    sort_order = sorter
    @sorted_by = sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    # construct query
    @q = client_source.ransack(params[:q])
    @non_hmis_clients = @q.result(distinct: false)

    # filter
    if clean_agency.present?
      @non_hmis_clients = @non_hmis_clients.where(agency: Agency.where(name: clean_agency))
    end
    if clean_cohort.present?
      @non_hmis_clients = @non_hmis_clients.where('active_cohort_ids @> ?', clean_cohort)
    end
    unless clean_available.nil?
      @non_hmis_clients = @non_hmis_clients.where(available: clean_available)
    end
    unless clean_family_member.nil?
      @non_hmis_clients = @non_hmis_clients.family_member(clean_family_member)
    end
    respond_to do |format|
      format.html do
        # paginate
        @page = params[:page].presence || 1
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
      @non_hmis_clients.each do |client|
        sheet << client.download_data
      end
    end
    xlsx.close
    send_data io.string,
      filename: "#{client_type}.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def new
    @non_hmis_client = client_source.new(agency_id: current_user.agency&.id)
    @assessment = build_assessment
    @contact_id = current_user.contact.id
  end

  def edit
    @contact_id = @non_hmis_client.contact_id
  end

  def new_assessment
    @assessment = build_assessment
    render :edit
  end

  def sorter
    @column = params[:sort]
    @direction = params[:direction]

    if @column.blank?
      @column = 'days_homeless_in_the_last_three_years'
      @direction = 'desc'
      sort_string = "#{@column} #{@direction}"
    else
      sort_string = sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.first[:order]
    end

    if ApplicationRecord.connection.adapter_name == 'PostgreSQL'
      sort_string += ' NULLS LAST'
    end
    return sort_string
  end

  def build_assessment
    assessment_type.constantize.new
  end

  def load_client
    begin
      @non_hmis_client = client_source.find params[:id].to_i
      @assessment = load_assessment || @non_hmis_client.current_assessment
    rescue
      client = NonHmisClient.find params[:id].to_i
      case client.type
      when 'DeidentifiedClient'
        redirect_to polymorphic_path([action_name, :deidentified_client], id: params[:id])
      when 'IdentifiedClient'
        redirect_to polymorphic_path([action_name, :identified_client], id: params[:id])
      when 'ImportedClient'
        redirect_to polymorphic_path([action_name, :imported_client], id: params[:id])
      end
    end
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
    if contact_id.present?
      contact = Contact.find(contact_id.to_i)
      return contact.user&.agency_id
    else
      return nil
    end
  end

  def set_active_filter
    @active_filter = filter_terms.map{|k| params[k].present?}.any?
  end

  def clean_agency
    NonHmisClient.possible_agencies.detect{|m| m.downcase == params[:agency]&.downcase}
  end

  def clean_cohort
    NonHmisClient.possible_cohorts.keys.detect{|m| m.to_i == params[:cohort]&.to_i}.to_s
  end

  def clean_available
    [true, false].detect{|m| m.to_s == params[:available]}
  end

  def clean_family_member
    [true, false].detect{|m| m.to_s == params[:family_member]}
  end

  def clean_client_params dirty_params
    dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
    dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?

    if can_edit_all_clients?
      contact_agency_id = agency_id_for_contact(dirty_params[:contact_id])
      dirty_params[:agency_id] = contact_agency_id if contact_agency_id.present?
    else
      dirty_params[:agency_id] = current_user.agency_id
    end

    dirty_params[:available] = dirty_params[:active_client] == '1' && dirty_params[:eligible_for_matching] == '1'

    return dirty_params
  end

  def clean_assessment_params dirty_params
    assessment_params = dirty_params.dig(:client_assessments_attributes, 0)
    return dirty_params unless assessment_params.present?

    assessment_params[:type] = assessment_type

    if assessment_params[:income_total_annual].present?
      assessment_params[:income_total_monthly] = assessment_params[:income_total_annual].to_i / 12
    end

    if assessment_params.has_key?(:youth_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:youth_rrh_aggregate] == 'adult' || assessment_params[:youth_rrh_aggregate] == 'both'
      assessment_params[:youth_rrh_desired] = true if assessment_params[:youth_rrh_aggregate] == 'youth' || assessment_params[:youth_rrh_aggregate] == 'both'
      assessment_params.extract![:youth_rrh_aggregate]
    end
    if assessment_params.has_key?(:dv_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:dv_rrh_aggregate] == 'dv' || assessment_params[:dv_rrh_aggregate] == 'both'
      assessment_params[:dv_rrh_desired] = true if assessment_params[:dv_rrh_aggregate] == 'non-dv' || assessment_params[:dv_rrh_aggregate] == 'both'
      assessment_params.extract![:dv_rrh_aggregate]
    end

    if assessment_params[:neighborhood_interests].present?
      assessment_params[:neighborhood_interests] = assessment_params[:neighborhood_interests]&.reject(&:blank?)&.map(&:to_i)
    end

    assessment_params[:user_id] = current_user.id

    return dirty_params
  end
end