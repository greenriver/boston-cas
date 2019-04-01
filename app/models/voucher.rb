class Voucher < ActiveRecord::Base
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  scope :available, -> { where available: true }
  belongs_to :sub_program
  belongs_to :unit
  belongs_to :creator, class_name: 'User', required: false, inverse_of: :vouchers, foreign_key: :user_id

  delegate :program, to: :sub_program

  has_one :opportunity, inverse_of: :voucher
  has_one :status_match, through: :opportunity
  has_one :successful_match, through: :opportunity

  has_many :client_opportunity_matches, through: :opportunity

  validate :cant_update_when_active_or_successful_match, unless: :skip_match_locking_validation
  validate :cant_have_unit_in_use
  validate :requires_unit_if_avaiable

  acts_as_paranoid
  has_paper_trail

  delegate :active_matches, to: :opportunity

  attr_accessor :building_id, :skip_match_locking_validation

  # Default to the building on the sub-program, if there is one.
  # If a unit has been assigned, make sure the building matches the unit.
  def building
    return sub_program.building unless unit.present?

    unit.building
  end

  # Default the units available to the voucher to the sub-program building.
  # If a unit has already been assigned, scope it to the associated building
  def units
    return sub_program.building.available_units_for_vouchers unless unit.present?

    [unit] + unit.building.available_units_for_vouchers.to_a
  end

  def units_including_unavailable
    return sub_program.building.units_for_vouchers unless unit.present?

    [unit] + unit.building.units_for_vouchers.to_a
  end

  def self.text_search(text)
    return none unless text.present?

    unit_matches = Unit.where(
      Unit.arel_table[:id].eq arel_table[:unit_id],
    ).text_search(text).exists

    sub_program_matches = SubProgram.where(
      SubProgram.arel_table[:id].eq arel_table[:sub_program_id],
    ).text_search(text).exists

    query = "%#{text}%"
    where(
      unit_matches.
      or(sub_program_matches),
    )
  end

  def self.associations_adding_requirements
    %i[unit sub_program]
  end

  def self.associations_adding_services
    %i[unit sub_program]
  end

  def available_at
    cursor = self

    while cursor
      if cursor.available
        previous = cursor.paper_trail.previous_version
        if previous.nil? || !previous.available
          return cursor.updated_at
        end
      end
      cursor = cursor.paper_trail.previous_version
    end

    nil
  end

  def changing_to_available?
    available? && available_changed?
  end

  def can_be_destroyed?
    !client_opportunity_matches.exists?
  end

  private def cant_update_when_active_or_successful_match
    if status_match.present?
      condition = status_match.successful? ? 'successful match' : 'match in progress'
      if available_changed? || unit_id_changed? || date_available_changed?
        errors.add :base, "Voucher #{id} is locked while there is a #{condition}"
      end
    end
  end

  private def cant_have_unit_in_use
    if unit.try(:in_use?) && unit_id_changed?
      errors.add :unit_id, 'Unit in use'
    end
  end

  private def requires_unit_if_avaiable
    if available && unit_id.blank? && sub_program.has_buildings?
      errors.add :unit_id, 'Unit required to make the voucher available'
    end
  end
end
