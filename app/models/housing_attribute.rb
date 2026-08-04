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

  def self.attribute_catalog
    with_value.pluck(:name, :value).each_with_object(Hash.new { |h, k| h[k] = [] }) do |(n, v), h|
      h[n] << v
    end.tap { |h| h.each_value { |vals| vals.sort!.uniq! } }
  end

  def self.name_summary
    counts = group(:name, :include_value).count
    representative_ids = group(:name, :include_value).minimum(:id)

    counts.map do |(name, include_value), count|
      OpenStruct.new(
        name: name,
        type: include_value ? 'Attribute' : 'Amenity',
        count: count,
        id: representative_ids[[name, include_value]],
      )
    end.sort_by { |n| [n.name.to_s.downcase, n.type] }
  end

  def self.value_summary(name)
    where(name: name).with_value.group(:value).count.
      sort_by { |value, _| value.to_s }.
      map { |value, count| OpenStruct.new(value: value, count: count) }
  end

  def self.rename(old_name:, new_name:, include_value:)
    return if new_name.blank? || new_name == old_name

    transaction do
      where(name: old_name, include_value: include_value).find_each { |ha| ha.update!(name: new_name) }
    end
  end

  def self.rename_value(name:, old_value:, new_value:)
    return if old_value.blank? || new_value.blank? || old_value == new_value

    transaction do
      where(name: name, value: old_value).with_value.find_each { |ha| ha.update!(value: new_value) }
    end
  end

  def existing_values(for_attribute: nil)
    for_attribute ||= name
    return [] if for_attribute.blank?

    self.class.with_value.where(name: for_attribute).pluck(:value).uniq.sort
  end
end
