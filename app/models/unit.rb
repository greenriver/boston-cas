###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Unit < ActiveRecord::Base
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
    Voucher.exists?(unit_id: id) || Opportunity.exists?(unit_id: id)
  end

  def self.text_search(text)
    return none unless text.present?

    building_matches = Building.where(
      Building.arel_table[:id].eq arel_table[:building_id]
    ).text_search(text).exists

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
