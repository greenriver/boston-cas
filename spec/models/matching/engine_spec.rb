require 'rails_helper'

RSpec.describe Matching::Engine, type: :model do
  let!(:client) { create :client }  
  let!(:program_with_all_rules) { 
    # make sure we have all of the rules
    CasSeeds::Rules.new.run!
    requirements = Rule.all.map do |rule|
      create :requirement, rule: rule, positive: true
    end
    create :program, requirements: requirements
  }
  let!(:complex_sub_program) { create :sub_program, program: program_with_all_rules }
  let!(:complex_voucher) { create :voucher, sub_program: complex_sub_program }
  let!(:complex_opportunity) { create :opportunity, voucher: complex_voucher }
  let!(:simple_program) {
    requirement = create :requirement, rule: Rules::AgeGreaterThanEightteen.first, positive: true
    create :program, requirements: [requirement]
  }
  let!(:simple_sub_program) { create :sub_program, program: simple_program }
  let!(:simple_voucher) { create :voucher, sub_program: simple_sub_program }
  let!(:simple_opportunity) { create :opportunity, voucher: simple_voucher }
  
  describe "engine_modes" do
    it 'contains VI-SPDAT Priority Score' do
      expect( Matching::Engine.engine_modes.keys ).to include "VI-SPDAT Priority Score"
    end
  end

  describe "engine runs" do
    it 'and does not throw an error' do
      expect { Matching::RunEngineJob.perform_now }.to_not raise_error
    end
    it 'and finds a match' do
      expect {
        Matching::RunEngineJob.perform_now
      }.to change(ClientOpportunityMatch, :count).by(1)
    end
    it ' and client match is the same as opportunity active match' do
      expect(client.client_opportunity_matches.first).to eq(simple_opportunity.active_match)
    end
  end

end
Client.arel_table[:date_of_birth]