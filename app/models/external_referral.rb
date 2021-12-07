###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ExternalReferral < ApplicationRecord
  acts_as_paranoid

  belongs_to :client
  belongs_to :user
end
