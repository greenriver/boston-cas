module MatchPrioritization
  class Base < ActiveRecord::Base
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
        MatchPrioritization::DaysHomelessLastThreeYears,
        MatchPrioritization::DaysHomelessLastThreeYearsRandomTieBreaker,
        MatchPrioritization::AssessmentScore,
        MatchPrioritization::AssessmentScoreLengthHomelessTieBreaker,
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

    def self.column_name
      raise NotImplementedError
    end

    def self.prioritization_for_clients(scope)
      raise NotImplementedError
    end

    def prioritization_for_clients(scope)
      self.class.prioritization_for_clients(scope)
    end

    def title
      self.class.title
    end

    def column_name
      self.class.column_name
    end

    def self.c_t
      c_t = Client.arel_table
    end
  end
end
