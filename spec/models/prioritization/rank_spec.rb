require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe MatchPrioritization::Rank, type: :model do
  CasSeeds::Rules.new.run!
  # MatchRoutes::Base.ensure_all
  # MatchPrioritization::Base.ensure_all

  let(:priority) { create :priority_rank }
  let(:tag) { create :tag }
  let(:route) { create :default_route, match_prioritization: priority, tag_id: tag.id }
  let!(:matching_client_1) { create :client, tags: {tag.id => 2} }
  let!(:matching_client_2) { create :client, tags: {tag.id => 3} }
  let!(:non_matching_client) { create :client }

  let!(:simple_program) {
    requirement = create :requirement, rule: Rules::TaggedWith.first, positive: true, variable: tag.id
    create :program, requirements: [requirement], match_route_id: route.id
  }
  let!(:simple_sub_program) { create :sub_program, program: simple_program }
  let!(:simple_voucher) { create :voucher, sub_program: simple_sub_program }
  let!(:simple_opportunity) { create :opportunity, voucher: simple_voucher }

  describe "engine runs" do
    it 'and does not throw an error' do
      binding.pry
      expect { Matching::RunEngineJob.perform_now }.to_not raise_error
    end
    it 'and finds a match' do
      expect {
        Matching::RunEngineJob.perform_now
      }.to change(ClientOpportunityMatch, :count).by(2)
    end
    it ' and client match is the same as opportunity active match' do
      Matching::RunEngineJob.perform_now
      expect(matching_client_1.client_opportunity_matches.first).to eq(simple_opportunity.active_matches.first)
    end
  end
end