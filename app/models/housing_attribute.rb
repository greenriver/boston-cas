###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class HousingAttribute < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :housingable, polymorphic: true

  scope :with_value, -> { where(include_value: true) }
  scope :without_value, -> { where(include_value: false) }

  validates_presence_of :name
  validates :value, presence: true, if: :include_value?

  def self.existing_attributes
    with_value.pluck(:name).uniq.sort
  end

  def self.existing_amenities
    without_value.pluck(:name).uniq.sort
  end

  def existing_values(for_attribute: nil)
    for_attribute ||= name
    return [] if for_attribute.blank?

    self.class.with_value.where(name: for_attribute).pluck(:value).uniq.sort
  end
end
