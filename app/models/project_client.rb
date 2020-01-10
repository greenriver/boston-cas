###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ProjectClient < ActiveRecord::Base

  has_one :client, required: false, primary_key: :client_id, foreign_key: :id

  belongs_to :data_source, required: false

  scope :in_data_source, -> (data_source) do
    joins(:data_source).merge(DataSource.where(id: data_source.id))
  end

  scope :available, -> do
    where(sync_with_cas: true)
  end

  scope :has_client, -> do
    where.not(client_id: nil).joins(:client)
  end

  scope :needs_client, -> do
    where(
      arel_table[:client_id].eq(nil).or(
        arel_table[:client_id].not_in(Client.pluck(:id))
      )
    )
  end

  scope :update_pending, -> do
    where(needs_update: true)
  end

  def is_deidentified?
    NonHmisClient.where(id: self.id_in_data_source, identified: false).exists?
  end

  def is_identified?
    NonHmisClient.where(id: self.id_in_data_source, identified: true).exists?
  end

  # Availability is now determined solely based on the manually set sync_with_cas
  # column.  This generally maps to the chronically homeless list
  def available?
    self.sync_with_cas
  end

  def substance_abuse?
    case substance_abuse_problem
      when /.*refused.*/i,
      /client doesn't know/i,
      /no/i,
      /data not collected/i,
      nil
        return false
    end
    return true
  end

  # Attempt to find matching contacts for data coming from the warehouse
  def shelter_agency_contacts
    default_shelter_agency_contacts&.map do |email|
      Contact.where(Contact.arel_table[:email].matches(email))&.first
    end&.compact || []
  end

  def self.calculate_vispdat_priority_score(vispdat_score:, days_homeless:, veteran_status:)
    return nil unless vispdat_score.present?
    if Config.get(:vispdat_prioritization_scheme) == 'veteran_status'
      prioritization_bump = 0
      if veteran_status
        prioritization_bump = 100
      end
      vispdat_score + prioritization_bump
    else # Default Config.get(:vispdat_prioritization_scheme) == 'length_of_time'
      vispdat_prioritized_days_score = if days_homeless >= 1095
        1095
      elsif days_homeless >= 730
        730
      elsif days_homeless >= 365 && vispdat_score >= 8
        365
      else
        0
      end
      vispdat_score + vispdat_prioritized_days_score
    end
  end

  def self.vispdat_prioritization_schemes
    {
      'Veteran Status' => 'veteran_status',
      'Length of Time' => 'length_of_time',
    }
  end
end
