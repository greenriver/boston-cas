###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Building < ApplicationRecord
  include InheritsRequirementsFromServicesOnly
  include HasRequirements
  include ManagesServices
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  has_paper_trail

  belongs_to :subgrantee, optional: true
  belongs_to :data_source
  has_many :building_clients
  has_many :building_contacts, dependent: :destroy, inverse_of: :building
  has_many :contacts, through: :building_contacts
  has_many :building_programs

  has_many :building_services, dependent: :destroy, inverse_of: :building
  has_many :services, through: :building_services

  has_many :units, inverse_of: :building
  has_many :opportunities, inverse_of: :building
  has_many :housing_attributes, as: :housingable
  has_many :housing_media_links, as: :housingable

  validates_presence_of :name

  def available_units
    Unit.where(building_id: id, available: true)
  end

  # available units that aren't also currently in use
  def available_units_for_vouchers
    units_for_vouchers.where.not(id: unavailable_units_for_vouchers_ids)
  end

  def units_for_vouchers
    # Include unit where there is no voucher using it
    # OR the voucher is not attached to an open match
    units_with_no_voucher = units.where.not(id: Voucher.with_unit.select(:unit_id))
    units_not_on_open_matches = units.where.not(id: Voucher.with_unit.on_open_match.select(:unit_id))
    units.where(id: units_with_no_voucher.select(:id)).or(units.where(id: units_not_on_open_matches.select(:id)))
  end

  def unavailable_units_for_vouchers_ids
    # Any unit that is marked unavailable
    # and any unit already on a voucher on an open match
    # add any unit on a voucher with no match
    unavailable_ids = units.where(available: false).pluck(:id)
    unavailable_ids += units.where(id: Voucher.not_archived.with_unit.on_open_match.select(:unit_id)).pluck(:id)
    unavailable_ids + Voucher.not_archived.with_unit.where.not(id: Opportunity.joins(:client_opportunity_matches).select(:voucher_id)).pluck(:unit_id)
  end

  def fake_opportunites(n) # rubocop:disable Naming/MethodParameterName
    (0 .. n).map do |i|
      opportunities.build do |opp|
        opp.name = "#{name} ##{i + 1}"
        opp.available = Faker::Boolean.boolean(0.085) ? true : false
        opp.address = Faker::Address.street_address
        opp.city = _('Boston')
        opp.state = 'MA'
        opp.zip_code = Faker::Address.zip_code
      end
    end
  end

  def self.text_search(text)
    return none unless text.present?

    subgrantee_matches = Subgrantee.where(Subgrantee.arel_table[:id].eq arel_table[:subgrantee_id]).
      text_search(text).
      arel.
      exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(arel_table[:building_type].matches(query))
      .or(arel_table[:address].matches(query))
      .or(arel_table[:zip_code].matches(query))
      .or(subgrantee_matches),
    )
  end

  def self.associations_adding_requirements
    [:services, :subgrantee]
  end

  def self.associations_adding_services
    [:subgrantee]
  end

  def building_address
    b_address = []
    if address.present?
      address_line_1 = address.strip
      if city.present?
        address_line_2 = "#{city}, #{state} #{zip_code}"
      else
        address_line_2 = zip_code
      end
      b_address << address_line_1
      b_address << address_line_2
    end
    b_address
  end

  def map_link
    link = ''
    link = "http://maps.google.com/?q=#{address.strip}," if address.present?
    # link += "%20#{city}," if city.present?
    # link += "%20#{state}" if state.present?
    link += "%20#{zip_code}" if zip_code.present?

    link
  end
end
