###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class VeteranStatus < ApplicationRecord
  has_many :clients, primary_key: :numeric, foreign_key: :veteran_status_id
end
