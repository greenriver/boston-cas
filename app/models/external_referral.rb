###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ExternalReferral < ApplicationRecord
  acts_as_paranoid

  belongs_to :client
  belongs_to :user
end
