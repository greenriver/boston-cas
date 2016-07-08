require 'test_helper'


class ClientOpportunityMatchTest < ActiveSupport::TestCase
  
  attr_reader :subject
  def setup
    @subject = ClientOpportunityMatch.new
  end
  
  def test_match_recommendation_dnd_staff_decision
    assert_kind_of MatchDecisions::MatchRecommendationDndStaff, subject.match_recommendation_dnd_staff_decision
  end
  
end