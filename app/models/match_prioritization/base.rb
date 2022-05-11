###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class Base < ApplicationRecord
    self.table_name = :match_prioritizations

    has_many :match_route, class_name: MatchRoutes::Base.name, foreign_key: :match_prioritization_id, primary_key: :id

    scope :available, -> do
      where(active: true).
        order(weight: :asc)
    end

    def self.prioritization_schemes
      [
        MatchPrioritization::FirstDateHomeless,
        MatchPrioritization::VispdatScore,
        MatchPrioritization::VispdatPriorityScore,
        MatchPrioritization::DaysHomeless,
        MatchPrioritization::DaysHomelessPopulations,
        MatchPrioritization::DaysHomelessLastThreeYears,
        MatchPrioritization::DaysHomelessLastThreeYearsRandomTieBreaker,
        MatchPrioritization::DaysHomelessLastThreeYearsAssessmentDate,
        MatchPrioritization::AssessmentScore,
        MatchPrioritization::AssessmentScoreLengthHomelessTieBreaker,
        MatchPrioritization::AssessmentScoreFundingTieBreaker,
        MatchPrioritization::Rank,
        MatchPrioritization::HoldsVoucherOn,
        MatchPrioritization::MatchGroup,
      ]
    end

    def self.ensure_all
      prioritization_schemes.each_with_index do |priority, i|
        priority.first_or_create(weight: i)
      end
    end

    def self.title
      raise NotImplementedError
    end

    def self.client_prioritization_value_method
      raise NotImplementedError
    end

    def self.prioritization_for_clients(scope, match_route:)
      raise NotImplementedError
    end

    def prioritization_for_clients(scope)
      self.class.prioritization_for_clients(scope, match_route: match_route.first)
    end

    def title
      self.class.title
    end

    def client_prioritization_value_method
      self.class.client_prioritization_value_method
    end

    def self.c_t
      Client.arel_table
    end

    def requires_tag?
      false
    end

    def important_days_homeless_calculations
      days_homeless_labels
    end

    private def days_homeless_labels
      {
        days_homeless: {
          label: _('Cumulative Days Homeless'),
          tooltip: _('Cumulative days homeless, all-time'),
        },
        hmis_days_homeless_last_three_years: {
          label: _('Days Homeless in Last Three Years from HMIS'),
          tooltip: _('Days in homeless enrollments, excluding any self-report'),
        },
        days_homeless_in_last_three_years: {
          label: _('Days Homeless in Last Three Years'),
          tooltip: _('Days homeless in the last three years including self-reported days'),
        },
        days_literally_homeless_in_last_three_years: {
          label: _('Days Literally Homeless in Last Three Years'),
          tooltip: _('Days in ES, SH or SO with no overlapping TH or PH'),
        },
      }
    end
  end
end
