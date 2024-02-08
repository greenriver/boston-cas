###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Voucher < ApplicationRecord
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include HasRequirements
  include MatchArchive

  scope :available, -> do
    where(available: true)
  end

  scope :archived, -> do
    where.not(archived_at: nil)
  end

  scope :not_archived, -> do
    where(archived_at: nil)
  end

  scope :with_unit, -> do
    where.not(unit_id: nil)
  end

  scope :on_open_match, -> do
    joins(:client_opportunity_matches).merge(ClientOpportunityMatch.open)
  end

  belongs_to :sub_program
  belongs_to :unit
  belongs_to :creator, class_name: 'User', optional: true, inverse_of: :vouchers, foreign_key: :user_id

  delegate :program, to: :sub_program

  has_one :opportunity, inverse_of: :voucher
  has_one :status_match, through: :opportunity
  has_one :successful_match, through: :opportunity

  has_many :client_opportunity_matches, through: :opportunity

  validate :cant_update_when_active_or_successful_match, unless: :skip_match_locking_validation
  validate :cant_have_unit_in_use
  validate :requires_unit_if_available

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
    return sub_program.building.units unless unit.present?

    unit.building.units.to_a
  end

  def self.confirmation_text
    # NOTE: this must match the string below, but because of the translation
    # engine's fickleness seems to need to be kept separate.
    'Translate this to add voucher confirmation'
  end

  def self.translated_confirmation_text
    Translation.translate('Translate this to add voucher confirmation')
  end

  def name
    'Voucher'
  end

  def self.text_search(text)
    return none unless text.present?

    unit_matches = Unit.where(Unit.arel_table[:id].eq arel_table[:unit_id]).
      text_search(text).arel.exists

    sub_program_matches = SubProgram.where(SubProgram.arel_table[:id].eq arel_table[:sub_program_id]).
      text_search(text).arel.exists

    # query = "%#{text}%"
    where(unit_matches.or(sub_program_matches))
  end

  def self.associations_adding_requirements
    [:unit, :sub_program]
  end

  def self.associations_adding_services
    [:unit, :sub_program]
  end

  def inherited_requirements_by_source
    {}
  end

  def self.preload_for_inherited_requirements
    all
  end

  def requirements_description
    requirements.map(&:name).compact.join ', '
  end

  def available_at
    cursor = self

    while cursor
      if cursor.available
        previous = cursor.paper_trail.previous_version
        return cursor.updated_at if previous.nil? || ! previous.available
      end
      cursor = cursor.paper_trail.previous_version
    end

    return nil
  end

  def changing_to_available?
    available? && available_changed?
  end

  def can_be_destroyed?
    ! client_opportunity_matches.in_process_or_complete.exists?
  end

  def can_be_archived?
    ! available && ! active_matches?
  end

  def active_matches?
    client_opportunity_matches.active.exists?
  end

  # Searching by client name
  scope :client_search, ->(text) do
    return none unless text.present?

    text.strip!
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
    end

    if first.present? && last.present?
      where = Client.arel_table[:first_name].lower.matches("%#{first.downcase}%").
        or(Client.arel_table[:last_name].lower.matches("%#{last.downcase}%"))
    elsif first.present?
      where = Client.arel_table[:first_name].lower.matches("%#{first.downcase}%")
    elsif last.present?
      where = Client.arel_table[:last_name].lower.matches("%#{last.downcase}%")
    else
      where = Client.arel_table[:first_name].lower.matches("%#{text.downcase}%").
        or(Client.arel_table[:last_name].lower.matches("%#{text.downcase}%"))
    end
    joins(status_match: :client).where(where)
  end

  private def cant_update_when_active_or_successful_match
    return unless status_match.present?
    return unless available_changed? || unit_id_changed? || date_available_changed?

    condition = status_match.successful? ? 'successful match' : 'match in progress'
    errors.add :base, "Voucher #{id} is locked while there is a #{condition}"
  end

  private def cant_have_unit_in_use
    return unless unit.try(:in_use?) && unit_id_changed?

    errors.add :unit_id, 'Unit in use'
  end

  private def requires_unit_if_available
    return unless changing_to_available? && unit_id.blank? && sub_program.has_buildings?

    errors.add :unit_id, 'Unit required to make the voucher available'
  end
end
