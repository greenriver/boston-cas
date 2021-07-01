###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class HousingMediaLink < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :housingable, polymorphic: true

  validates_presence_of :label
  validates_presence_of :url
end
