###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class HousingAttribute < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :housingable, polymorphic: true

  validates_presence_of :name
  validates_presence_of :value

  def existing_attributes
    HousingAttribute.pluck(:name).uniq.sort
  end

  def existing_values(for_attribute: nil)
    for_attribute ||= name
    return [] if for_attribute.blank?

    HousingAttribute.where(name: for_attribute).pluck(:value).uniq.sort
  end
end
