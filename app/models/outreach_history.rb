###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class OutreachHistory < ApplicationRecord
  belongs_to :non_hmis_client
  belongs_to :user

  def self.outreach_locations
    options = {
      'Generic Outreach Location' => 'Generic Outreach Location',
    }
    options.merge(distinct.where.not(outreach_name: nil).order(:outreach_name).pluck(:outreach_name).select(&:present?).map(&:strip).uniq.map { |v| [v, v] }.to_h)
  end
end
