class Opportunity < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  include SubjectForMatches # loads methods and relationships
  include HasRequirements
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  belongs_to :unit, inverse_of: :opportunities
  belongs_to :voucher, inverse_of: :opportunity

  delegate :sub_program, to: :voucher

  has_one :active_match, -> {where(active: true, closed: false)}, class_name: 'ClientOpportunityMatch'
  has_one :successful_match, -> {where closed: true, closed_reason: 'success'}, class_name: 'ClientOpportunityMatch'
  # active or successful
  has_one :status_match, -> {where arel_table[:active].eq(true).or(arel_table[:closed].eq(true).and(arel_table[:closed_reason].eq('success')))}, class_name: 'ClientOpportunityMatch'

  has_many :opportunity_contacts, dependent: :destroy, inverse_of: :opportunity
  has_many :contacts, through: :opportunity_contacts

  has_many :housing_subsidy_admin_contacts,
    -> { where opportunity_contacts: {housing_subsidy_admin: true} },
    class_name: 'Contact',
    through: :opportunity_contacts,
    source: :contact

  attr_accessor :program, :building, :units

  # after_save :run_match_engine_if_newly_available

  def self.text_search(text)
    return none unless text.present?

    unit_matches = Unit.where(
      Unit.arel_table[:id].eq arel_table[:unit_id]
    ).text_search(text).exists

    voucher_matches = Voucher.where(
      Voucher.arel_table[:id].eq arel_table[:voucher_id]
    ).text_search(text).exists

    where(
      unit_matches
      .or(voucher_matches)
    )
  end

  def self.max_candidate_matches
    20
  end

  def self.associations_adding_requirements
    [:unit, :voucher]
  end

  def self.associations_adding_services
    [:unit, :voucher]
  end
  
  def opportunity_details
    @_opportunity_detail ||= OpportunityDetails.build self
  end
  
  def newly_available?
    if available && available_changed?
      Matching::MatchAvailableClientsForOpportunityJob.perform_later(self)
    end
  end

  def prioritized_matches
    client_opportunity_matches.joins(:client).order('clients.calculated_first_homeless_night desc')
  end

  def self.available_stati
    [
      'Match in Progress',
      'Available',
      'Available in the future',
      'Successful',
    ]
  end
end
