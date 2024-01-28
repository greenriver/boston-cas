###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
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
        MatchPrioritization::DaysHomelessVeteransFamiliesYouth,
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

    def self.client_prioritization_summary_method
      nil
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

    def client_prioritization_summary_method
      self.class.client_prioritization_summary_method
    end

    def client_prioritization_summary(client, match_route)
      if self.class.client_prioritization_summary_method.present?
        fn = self.class.client_prioritization_summary_method
        return client.send(fn) if client.class.column_names.include?(fn.to_s)

        client.send(fn, match_route: match_route)
      elsif self.class.supporting_data_columns.present?
        self.class.supporting_data_columns.map { |key, func| "#{key}: #{func.call(client)}" }.join('; ')
      else
        raise NotImplementedError
      end
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

    def supporting_data_columns
      self.class.supporting_data_columns
    end

    def self.supporting_data_columns
      nil
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
