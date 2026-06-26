###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rule < ApplicationRecord
  self.table_name = 'rules'
  include MatchArchive

  has_many :requirements
  has_many :services, through: :building_services

  acts_as_paranoid
  has_paper_trail

  def always_apply?
    false
  end

  def clients_that_fit(_scope, _requirement, _opportunity = nil)
    raise "You need to define clients_that_fit on your Rule subclass #{self.class}."
  end

  def requirement_implied_by(_requirements)
    nil
    # Somewhat hard-coded logic (defined in subclasses) giving you a
    # requirement for this rule which a client will
    # definitely meet if they meet the given requirements, or no requirement.
  end

  def model_name
    ActiveModel::Name.new self, nil, 'rule'
  end

  def name_with_verb
    "#{verb} #{Translation.translate(name)}"
  end

  def description
    ''
  end

  def selection_note(context: nil) # rubocop:disable Lint/UnusedMethodArgument
    nil
  end

  VARIABLE_INPUT_TYPES = {
    'Rules::ActiveInCohort' => 'multi-select',
    'Rules::AgeGreaterThanX' => 'number',
    'Rules::AgeGreaterThanY' => 'number',
    'Rules::AssessmentCompletedWithin' => 'select',
    'Rules::AssessmentScoreGreaterThanSpecified' => 'select',
    'Rules::Bedroom' => 'select',
    'Rules::BedroomExact' => 'select',
    'Rules::Challenge' => 'multi-select',
    'Rules::EnrolledInHmisProjectTypeAnyPhNoMoveIn' => 'multi-select',
    'Rules::EnrolledInHmisProjectType' => 'multi-select',
    'Rules::EnrolledInHmisProject' => 'multi-select',
    'Rules::HasFileTags' => 'multi-select',
    'Rules::IncomeMaximum' => 'number',
    'Rules::IncomeMinimum' => 'number',
    'Rules::InterestedInNeighborhood' => 'select',
    'Rules::NonHmisAssessmentType' => 'multi-select',
    'Rules::Occupancy' => 'select',
    'Rules::RankBelow' => 'select',
    'Rules::Strength' => 'multi-select',
    'Rules::TaggedWith' => 'select',
    'Rules::UnshelteredDays' => 'select',
  }.freeze

  VARIABLE_LABELS = {
    'Rules::ActiveInCohort' => 'Cohort',
    'Rules::AgeGreaterThanX' => 'Age',
    'Rules::AgeGreaterThanY' => 'Age',
    'Rules::AssessmentCompletedWithin' => 'Assessment',
    'Rules::AssessmentScoreGreaterThanSpecified' => 'Assessment Score',
    'Rules::Bedroom' => 'Bedrooms',
    'Rules::BedroomExact' => 'Bedrooms',
    'Rules::Challenge' => 'Challenge',
    'Rules::EnrolledInHmisProjectTypeAnyPhNoMoveIn' => 'Project Types',
    'Rules::EnrolledInHmisProjectType' => 'Project Types',
    'Rules::EnrolledInHmisProject' => 'Projects',
    'Rules::HasFileTags' => 'File Tags',
    'Rules::IncomeMaximum' => 'Income',
    'Rules::IncomeMinimum' => 'Income',
    'Rules::InterestedInNeighborhood' => 'Neighborhood',
    'Rules::NonHmisAssessmentType' => 'Assessment Types',
    'Rules::Occupancy' => 'Occupancy',
    'Rules::RankBelow' => 'Rank',
    'Rules::Strength' => 'Strength',
    'Rules::TaggedWith' => 'Tag',
    'Rules::UnshelteredDays' => 'Days Unsheltered',
  }.freeze

  VARIABLE_OPTIONS_METHODS = {
    'Rules::ActiveInCohort' => :available_cohorts,
    'Rules::AssessmentCompletedWithin' => :available_options,
    'Rules::AssessmentScoreGreaterThanSpecified' => :available_scores,
    'Rules::Bedroom' => :available_number_of_bedrooms,
    'Rules::BedroomExact' => :available_number_of_bedrooms,
    'Rules::Challenge' => :available_challenges,
    'Rules::EnrolledInHmisProjectTypeAnyPhNoMoveIn' => :available_project_types,
    'Rules::EnrolledInHmisProjectType' => :available_project_types,
    'Rules::EnrolledInHmisProject' => :available_projects,
    'Rules::HasFileTags' => :available_tags,
    'Rules::InterestedInNeighborhood' => :available_neighborhoods,
    'Rules::NonHmisAssessmentType' => :available_assessments,
    'Rules::Occupancy' => :available_occupancy,
    'Rules::RankBelow' => :available_ranks,
    'Rules::Strength' => :available_strengths,
    'Rules::TaggedWith' => :available_tags,
    'Rules::UnshelteredDays' => :available_unsheltered_days,
  }.freeze

  def variable_requirement?
    false
  end

  def variable_input_type
    VARIABLE_INPUT_TYPES[self.class.name]
  end

  def variable_label
    VARIABLE_LABELS[self.class.name]
  end

  def variable_options
    method_name = VARIABLE_OPTIONS_METHODS[self.class.name]
    return [] unless method_name

    result = public_send(method_name)
    result.is_a?(Hash) ? result.to_a : result
  end

  def display_for_variable(_value)
    nil
  end

  def apply_to_match(match)
  end

  def associated_file_tags(_value)
    []
  end
end

class RuleDatabaseStructureMissing < StandardError; end
