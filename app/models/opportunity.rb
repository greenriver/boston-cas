###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Opportunity < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  include SubjectForMatches # loads methods and relationships
  include HasRequirements
  include Matching::HasOrInheritsRequirements
  include HasOrInheritsServices
  include MatchArchive

  belongs_to :voucher, inverse_of: :opportunity
  has_one :unit, through: :voucher

  has_one :sub_program, through: :voucher

  #has_one :active_match, -> {where(active: true, closed: false)}, class_name: 'ClientOpportunityMatch'
  has_many :active_matches, -> {where(active: true, closed: false)}, class_name: 'ClientOpportunityMatch'

  has_one :successful_match, -> {where closed: true, closed_reason: 'success'}, class_name: 'ClientOpportunityMatch'
  # active or successful
  has_one :status_match, -> {where arel_table[:active].eq(true).or(arel_table[:closed].eq(true).and(arel_table[:closed_reason].eq('success')))}, class_name: 'ClientOpportunityMatch'

  has_many :closed_matches, -> do
    where(closed: true).
    order(updated_at: :desc)
  end, class_name: 'ClientOpportunityMatch'

  has_many :opportunity_contacts, dependent: :destroy, inverse_of: :opportunity
  has_many :contacts, through: :opportunity_contacts

  has_many :housing_subsidy_admin_contacts,
    -> { where opportunity_contacts: {housing_subsidy_admin: true} },
    class_name: 'Contact',
    through: :opportunity_contacts,
    source: :contact

  has_one :match_route, through: :sub_program

  attr_accessor :program, :building, :units

  scope :with_voucher, -> do
    where.not(voucher_id: nil).joins(:voucher)
  end
  scope :available_candidate, -> do
    where(available_candidate: true)
  end

  scope :available_for_poaching, -> do
    available_candidate_ids = Opportunity.available_candidate.pluck(:id)
    unstarted_ids = Opportunity.joins(active_matches: :match_recommendation_dnd_staff_decision).
      merge(MatchDecisions::Base.pending).pluck(:id)
    Opportunity.where(id: available_candidate_ids + unstarted_ids)
  end
  # after_save :run_match_engine_if_newly_available

  scope :on_route, -> (route) do
    joins(sub_program: :program).merge(SubProgram.on_route(route))
  end

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

  def self.available_as_candidate
    where(available_candidate: true)
  end

  def self.ready_to_match
    available_as_candidate.matchable
  end

  def self.max_candidate_matches
    20
  end

  def self.associations_adding_requirements
    [:voucher]
  end

  def self.associations_adding_services
    [:voucher]
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
    ClientOpportunityMatch.prioritized_by_client(match_route, client_opportunity_matches.joins(:client))
  end

  def matches_client?(client)
    client_scope = Client.where(id: client.id)
    requirement_matches = requirements_with_inherited.map do |requirement|
      requirement.clients_that_fit(client_scope).exists?
    end
    attribute_matches = [
      add_unit_attributes_filter(client_scope).exists?
    ]
    (requirement_matches + attribute_matches).all?
  end

  def matching_clients(client_scope=Client.available_for_matching(match_route))
    requirements_with_inherited.each do |requirement|
      client_scope = client_scope.merge(requirement.clients_that_fit(client_scope))
    end
    client_scope = add_unit_attributes_filter(client_scope)
    client_scope.merge(Client.prioritized(match_route, client_scope))
  end

  def add_unit_attributes_filter(client_scope)
    if unit.present? && unit.elevator_accessible == false
      client_scope = client_scope.where(requires_elevator_access: false)
    end
    return client_scope
  end

  def notify_contacts_of_manual_match(match)
    Notifications::MatchInitiationForManualNotification.create_for_match! match
  end

  def notify_contacts_of_success(match)
    Notifications::HousingOpportunitySuccessfullyFilled.create_for_match! match
  end

  def self.available_stati
    [
      'Match in Progress',
      'Available',
      'Available in the future',
      'Successful',
    ]
  end

  def confidential?
    sub_program.confidential? || sub_program.program.confidential?
  end

  # Get visibility from the associated SubProgram
  delegate :visible_by?, to: :sub_program
  delegate :editable_by?, to: :sub_program

  scope :visible_by, ->(user) {
    joins(:sub_program).merge(SubProgram.visible_by(user))
  }
  scope :editable_by, ->(user) {
    joins(:sub_program).merge(SubProgram.editable_by(user))
  }

  # NOTE: This cleans up the opportunity and all associated items
  # making it as though this never happened.  Use with extreme caution
  # remove contacts from all matches <- this happens automatically (dependent destroy)
  # remove events from all matches <- this happens automatically (dependent destroy)
  # remove match decisions from all matches <- this happens automatically (dependent destroy)
  # remove all notifications for all matches
  # update all matched clients available_candidate true
  # remove all matches
  # remove voucher
  # remove self (opportunity)

  def stop_matches_and_remove_entire_history_from_existance!
    Opportunity.transaction do
      client_opportunity_matches.each do |match|
        match.client.update(available: true)
        match.client.make_unavailable_in(match_route: match_route)
        match.client_opportunity_match_contacts.destroy_all
        match.notifications.destroy_all
        match.destroy
      end
      voucher&.destroy
      destroy
    end
    SubProgram.all.each(&:update_summary!)
  end
end
