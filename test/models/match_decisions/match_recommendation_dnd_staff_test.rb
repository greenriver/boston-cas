require 'test_helper'

module MatchDecisions
  class MatchRecommendationDndStaffTest < ActiveSupport::TestCase
    
    attr_reader :subject, :match
    
    def setup
      @match = ClientOpportunityMatch.new
      @subject = MatchDecisions::MatchRecommendationDndStaff.new match: match
    end
    
    def test_label
      assert_predicate subject.label, :present?
    end
    
    def test_contact_name_delegates_to_contact
      allow(subject).to receive(:contact) do
         instance_double(Contact, full_name: 'Testy McTester')
       end
       assert_equal 'Testy McTester', subject.contact_name
    end

    def test_to_param
      assert_equal 'match_recommendation_dnd_staff', subject.to_param
    end
    
    
  end
end