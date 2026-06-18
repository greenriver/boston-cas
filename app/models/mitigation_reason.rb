###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class MitigationReason < ApplicationRecord
  scope :active, -> do
    where(active: true)
  end
end
