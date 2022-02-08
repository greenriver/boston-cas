###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Unit < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive
  include InheritsRequirementsFromServicesOnly
  include HasRequirements
  include Matching::HasOrInheritsRequirements

  belongs_to :building, inverse_of: :units
  has_many :vouchers, inverse_of: :unit
  has_many :opportunities, through: :vouchers
  has_one :active_voucher, -> { where available: true}, class_name: 'Voucher'
  has_one :opportunity, through: :active_voucher
  has_many :housing_attributes, as: :housingable
  has_many :housing_media_links, as: :housingable

  delegate :active_matches, to: :active_voucher
  delegate :program, to: :active_voucher

  validates :name, presence: true

  def hmis_managed?
    return true if id_in_data_source
    return false
  end

  def services
    []
  end

  def in_use?
    # Unit is in use if a voucher contains its unit_id
    # AND (the voucher has never been involved in a match
    #   OR the match is open)
    voucher_never_used = Voucher.where(unit_id: id).where.not(id: Opportunity.select(:voucher_id)).exists?
    voucher_on_open_match = Voucher.on_open_match.exists?(unit_id: id)
    voucher_never_used || voucher_on_open_match
  end

  def apply_default_housing_attributes
    building.housing_attributes&.each do |a|
      housing_attributes.create(
        name: a.name,
        value: a.value,
      )
    end
  end

  def self.text_search(text)
    return none unless text.present?

    building_matches = Building.where(
      Building.arel_table[:id].eq arel_table[:building_id]
    ).text_search(text).arel.exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(building_matches)
    )
  end

  def self.associations_adding_requirements
    [:building]
  end

  def self.associations_adding_services
    [:building]
  end
end
