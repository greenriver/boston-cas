###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class HousingMediaLink < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :housingable, polymorphic: true

  validates :label, presence: true
  validates :url, presence: true, url: true
end
