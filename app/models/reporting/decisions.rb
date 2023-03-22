###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Reporting::Decisions < ApplicationRecord
  include ArelHelper

  belongs_to :client, foreign_key: :cas_client_id

  scope :started_between, ->(range) do
    where(match_started_at: range.begin.beginning_of_day .. range.end.end_of_day)
  end

  scope :ended_between, ->(range) do
    terminated.
      where(updated_at: (range.begin.beginning_of_day .. range.end.end_of_day))
  end

  scope :open_between, ->(range) do
    at = arel_table
    # Excellent discussion of why this works:
    # http://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
    d_1_start = range.begin.beginning_of_day # these are timestamps
    d_1_end = range.end.end_of_day # these are timestamps
    d_2_start = at[:match_started_at]
    d_2_end = at[:updated_at]
    # Currently does not count as an overlap if one starts on the end of the other
    where(d_2_end.gteq(d_1_start).or(d_2_end.eq(nil)).and(d_2_start.lteq(d_1_end)))
  end

  scope :on_route, ->(limit) do
    routes = MatchRoutes::Base.find(Array.wrap(limit))
    route_names = routes.map(&:title)

    where(match_route: route_names)
  end

  scope :program_type, ->(limit) do
    where(program_type: limit)
  end

  scope :associated_with_agency, ->(limit) do
    # joins are hard through polymorphic associations...
    program_names = EntityViewPermission.where(entity_type: 'Program', editable: true, agency_id: limit).
      map { |p| p.entity.name }
    where(program_name: program_names)
  end

  scope :in_household_type, ->(limit) do
    options = limit.map do |t|
      case t
      when :individual
        c_t[:family_member].eq(false)
      when :individual_adult
        c_t[:family_member].eq(false).and(age_on_date.gteq(18))
      when :individual_child
        c_t[:family_member].eq(false).and(age_on_date.lt(18))
      when :adult_and_child
        c_t[:family_member].eq(true).and(c_t[:child_in_household].eq(true))
      when :parenting_youth
        c_t[:family_member].eq(true).and(c_t[:child_in_household].eq(true).and(age_on_date.lteq(24)))
      end
    end.reduce(&:or)
    joins(:client).
      where(options)
  end

  scope :veteran_status, ->(limit) do
    options = [].tap do |opt|
      opt << false if limit.include?(:non_veteran)
      opt << true if limit.include?(:veteran)
    end

    joins(:client).
      where(c_t[:veteran].in(options))
  end

  scope :age_range, ->(limit) do
    options = [].tap do |opt|
      opt << (0..17) if limit.include?(:under_eighteen)
      opt << (18..24) if limit.include?(:eighteen_to_twenty_four)
      opt << (25..29) if limit.include?(:twenty_five_to_twenty_nine)
      opt << (30..39) if limit.include?(:thirty_to_thirty_nine)
      opt << (40..49) if limit.include?(:forty_to_forty_nine)
      opt << (50..54) if limit.include?(:fifty_to_fifty_four)
      opt << (55..59) if limit.include?(:fifty_five_to_fifty_nine)
      opt << (60..61) if limit.include?(:sixty_to_sixty_one)
      opt << (61..125) if limit.include?(:over_sixty_one)
    end
    ages = options.map(&:to_a).flatten.uniq
    joins(:client).
      where(age_on_date.in(ages))
  end

  scope :gender, ->(limit) do
    options = limit.map { |g| c_t[g].eq(true) }.reduce(&:or)
    joins(:client).
      where(options)
  end

  scope :race, ->(limit) do
    options = limit.map { |g| c_t[g].eq(true) }.reduce(&:or)
    joins(:client).
      where(options)
  end

  scope :ethnicity, ->(limit) do
    # Ethnicity is mapped through a lookup table
    values = [].tap do |vals|
      vals << Ethnicity.find_by(text: 'Non-Hispanic/Non-Latino').numeric if limit.include?(:non_hispanic)
      vals << Ethnicity.find_by(text: 'Hispanic/Latino').numeric if limit.include?(:hispanic)
    end

    joins(:client).
      where(c_t[:ethnicity_id].in(values))
  end

  scope :disability, ->(limit) do
    options = limit.map do |d|
      case d
      when :hiv_aids
        c_t[:hiv_aids].eq(true).or((c_t[:hiv_positive].eq(true)))
      when :developmental_disability
        c_t[:developmental_disability].eq(1)
      when :disability_verified_on
        c_t[:disability_verified_on].not_eq(nil)
      else # Others are booleans
        c_t[d].eq(true)
      end
    end.reduce(&:or)
    joins(:client).
      where(options)
  end

  scope :current_step, -> do
    where(current_step: true)
  end

  # Only steps that actually took place
  # this is an approximation, where the updated timestamp is more than 9 seconds
  # after the created timestamp
  scope :activated, -> do
    where(
      Arel::Nodes::Subtraction.new(
        r_d_t[:updated_at].extract(:epoch),
        r_d_t[:created_at].extract(:epoch),
      ).gt(9),
    )
  end

  IN_PROGRESS = ['In Progress', 'Stalled'].freeze

  scope :in_progress, -> do
    where(terminal_status: IN_PROGRESS)
  end

  scope :ongoing_not_stalled, -> do
    where(current_status: 'In Progress')
  end

  scope :stalled, -> do
    where(current_status: 'Stalled')
  end

  scope :terminated, -> do
    where.not(terminal_status: IN_PROGRESS)
  end

  scope :success, -> do
    where(terminal_status: 'Success')
  end

  scope :unsuccessful, -> do
    where(terminal_status: ['Pre-empted', 'Rejected'])
  end

  scope :has_reason, ->(reason) do
    where(decline_reason: reason).
      or(where(administrative_cancel_reason: reason))
  end

  # This filters the decisions to ones with a reason field, but does not otherwise narrow the scope
  scope :has_a_reason, -> do
    where.not(decline_reason: nil).
      or(where.not(administrative_cancel_reason: nil))
  end

  scope :preempted, -> do
    where(terminal_status: 'Pre-empted')
  end

  scope :declined, -> do
    where(terminal_status: 'Declined')
  end

  scope :rejected, -> do
    where(terminal_status: 'Rejected')
  end
end
