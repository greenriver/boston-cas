###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ShelterHistory < ApplicationRecord
  belongs_to :non_hmis_client
  belongs_to :user

  def self.shelter_locations
    added = distinct.where.not(shelter_name: nil).order(:shelter_name).pluck(:shelter_name).select(&:present?).map(&:strip).uniq.map { |v| [v, v] }.to_h
    forced = [
      '112 Southampton Street- Men’s Shelter – only current guests',
      'Asian Task Force Against Domestic Violence',
      'Boston Night Center',
      'Boston Rescue Mission',
      'Bridge Over Troubled Water',
      'Casa Myrna Vazquez',
      'Dept. of Mental Health Safe Haven',
      'Elizabeth Stonehouse',
      'Finex House',
      'Liberty Village',
      'New England Center & Home for Veterans',
      'Pine Street Inn – only current guests',
      'Rosie’s Place',
      'Woods Mullen – only current guests',
      'Other - Type the name of the shelter and press enter',
      'None',
    ].map { |v| [v, v] }.to_h
    forced.merge(added)
  end

  def self.outreach_programs
    [
      'Boston Healthcare for the Homeless',
      'Bridge Over Troubled Waters',
      'Eliot',
      'Pine Street Outreach',
      'Other - Type the name of the shelter and press enter',
      'None',
    ].map { |v| [v, v] }.to_h
  end
end
