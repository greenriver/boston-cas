###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class LoginActivity < ApplicationRecord
  belongs_to :user, polymorphic: true

  def location_description
    description = ''
    description += "#{city}, " if city
    description += "#{region} " if region
    description += country if country
    description
  end
end
