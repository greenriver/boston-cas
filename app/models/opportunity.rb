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
    c_t = Client.arel_table
    case Config.get(:engine_mode)
    when 'first-date-homeless'
      client_opportunity_matches.joins(:client).
        order(c_t[:calculated_first_homeless_night].asc)
    when 'cumulative-homeless-days'
      client_opportunity_matches.joins(:client).
        order(c_t[:days_homeless].desc)
    when 'homeless-days-last-three-years'
      client_opportunity_matches.joins(:client).
      order(c_t[:days_homeless_in_last_three_years].desc)
    when 'vi-spdat'
      client_opportunity_matches.joins(:client).
        where.not(clients: {vispdat_score: nil}).
        order(c_t[:vispdat_score].desc)
    when 'vispdat-priority-score'
      client_opportunity_matches.joins(:client)
        .where.not(clients: { vispdat_priority_score: nil }) 
        .order(c_t[:vispdat_priority_score].desc) 
    else
      raise NotImplementedError
    end
  end

  def self.available_stati
    [
      'Match in Progress',
      'Available',
      'Available in the future',
      'Successful',
    ]
  end

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
        match.client.update(available_candidate: true, available: true)
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
