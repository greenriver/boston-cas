require 'test_helper'


module Notifications
  class MatchRecommendationDndStaffTest < ActiveSupport::TestCase
    
    attr_reader :subject, :match
    def setup
      @match = ClientOpportunityMatch.new
      @subject = Notifications::MatchRecommendationDndStaff.new match: match
    end
    
    def test_decision
      allow(match).to receive(:match_recommendation_dnd_staff_decision) { 'A Decision' }
      assert_equal 'A Decision', subject.decision
    end
    
  end
end

