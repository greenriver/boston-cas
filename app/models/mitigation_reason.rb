###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MitigationReason < ApplicationRecord
  scope :active, -> do
    where(active: true)
  end
end
