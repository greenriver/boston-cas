###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ShelterHistory < ApplicationRecord
  belongs_to :non_hmis_client
  belongs_to :user

  def self.shelter_locations
    distinct.where.not(shelter_name: nil).order(:shelter_name).pluck(:shelter_name).select(&:present?).map(&:strip).uniq.map { |v| [v, v] }.to_h
  end
end
