class Unit < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  belongs_to :building, inverse_of: :units
  has_many :opportunities, inverse_of: :unit
  has_many :project_clients, primary_key: :roomid, foreign_key: :last_homeless_night_roomid
  has_many :vouchers, inverse_of: :unit
  has_one :active_voucher, -> { where available: true}, class_name: 'Voucher'
  has_one :opportunity, through: :active_voucher 

  delegate :active_match, to: :active_voucher

  def hmis_managed?
    return true if id_in_data_source
    return false
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
