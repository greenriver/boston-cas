###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class UnitAttribute < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :unit

  validates_presence_of :name
  validates_presence_of :value

  def existing_attributes
    UnitAttribute.pluck(:name).uniq.sort
  end

  def existing_values(for_attribute: nil)
    for_attribute ||= name
    return [] if for_attribute.blank?

    UnitAttribute.where(name: for_attribute).pluck(:value).uniq.sort
  end
end