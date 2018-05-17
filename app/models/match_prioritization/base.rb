module MatchPrioritization
  class Base < ActiveRecord::Base
    self.table_name = :match_prioritizations

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
        MatchPrioritization::AssessmentScore,
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

    def self.slug
      raise NotImplementedError
    end  
    
    def title
      self.class.title
    end

  end
end
