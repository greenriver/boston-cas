###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
