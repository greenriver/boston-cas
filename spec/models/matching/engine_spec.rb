require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Matching::Engine, type: :model do
  CasSeeds::Rules.new.run!
  # MatchRoutes::Base.ensure_all
  # MatchPrioritization::Base.ensure_all
  # MatchRoutes::ProviderOnly.first.update(should_cancel_other_matches: false)
  let!(:priority) { create :priority_vispdat_priority }
  let!(:route) { create :default_route, match_prioritization: priority }
  let!(:client) { create :client }
  let!(:program_with_all_rules) do
    # make sure we have all of the rules
    requirements = Rule.all.map do |rule|
      if rule.variable_requirement?
        create :requirement, rule: rule, positive: true, variable: 1
      else
        create :requirement, rule: rule, positive: true
      end
    end
    create :program, requirements: requirements, match_route_id: route.id
  end
  let!(:complex_sub_program) { create :sub_program, program: program_with_all_rules }
  let!(:complex_voucher) { create :voucher, sub_program: complex_sub_program }
  let!(:complex_opportunity) { create :opportunity, voucher: complex_voucher }
  let!(:simple_program) do
    requirement = create :requirement, rule: Rules::AgeGreaterThanEightteen.first, positive: true
    create :program, requirements: [requirement], match_route_id: route.id
  end
  let!(:simple_sub_program) { create :sub_program, program: simple_program }
  let!(:simple_voucher) { create :voucher, sub_program: simple_sub_program }
  let!(:simple_opportunity) { create :opportunity, voucher: simple_voucher }

  let!(:income_program) do
    requirement = create :requirement, rule: Rules::IncomeLessThanEightyPercentAmi.first, positive: true
    create :program, requirements: [requirement], match_route_id: route.id
  end
  let!(:income_sub_program) { create :sub_program, program: simple_program }
  let!(:income_voucher) { create :voucher, sub_program: income_sub_program }
  let!(:income_opportunity) { create :opportunity, voucher: income_voucher }

  let!(:voucher_requirement_sub_program) { create :sub_program, program: simple_program }
  let!(:voucher_requirement_voucher) { create :voucher, sub_program: simple_sub_program, requirements: [Requirement.new(rule: Rules::Veteran.first, positive: true)] }
  let!(:voucher_requirement_opportunity) { create :opportunity, voucher: voucher_requirement_voucher }

  describe 'engine runs' do
    it 'and does not throw an error' do
      expect { Matching::RunEngineJob.new.perform }.to_not raise_error
    end
    it 'and finds a match' do
      expect do
        Matching::RunEngineJob.new.perform
      end.to change(ClientOpportunityMatch, :count).by(1)
    end
    it 'and client matches one of the opportunities' do
      Matching::RunEngineJob.new.perform
      expect(ClientOpportunityMatch.first.client_id).to eq(client.id)
      expect(ClientOpportunityMatch.first.opportunity).to be_in([simple_opportunity, complex_opportunity, income_opportunity, voucher_requirement_opportunity])
    end
  end
end
