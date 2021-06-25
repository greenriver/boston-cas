###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
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
    available_units.where.not(id: Voucher.where.not(unit_id: nil).select(:unit_id)).where.not(id: Opportunity.where.not(unit_id: nil).select(:unit_id))
  end

  def units_for_vouchers
    units.where.not(id: Voucher.where.not(unit_id: nil).select(:unit_id)).where.not(id: Opportunity.where.not(unit_id: nil).select(:unit_id))
  end

  def unavailable_units_for_vouchers_ids
    units_for_vouchers.where(available: false).pluck(:id)
  end

  def fake_opportunites(n)
    (0 .. n).map do |i|
      opportunities.build do |opp|
        opp.name = "#{name} ##{i+1}"
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

    subgrantee_matches = Subgrantee.where(
      Subgrantee.arel_table[:id].eq arel_table[:subgrantee_id]
    ).text_search(text).arel.exists

    query = "%#{text}%"
    where(
      arel_table[:name].matches(query)
      .or(arel_table[:building_type].matches(query))
      .or(arel_table[:address].matches(query))
      .or(arel_table[:zip_code].matches(query))
      .or(subgrantee_matches)
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
    if address.present?
      link = "http://maps.google.com/?q=#{address.strip},"
    end
    if city.present?
      #link += "%20#{city},"
    end
    if state.present?
      #link += "%20#{state}"
    end
    if zip_code.present?
      link += "%20#{zip_code}"
    end
  end
end
