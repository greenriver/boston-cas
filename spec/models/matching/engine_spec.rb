require 'rails_helper'

RSpec.describe Matching::Engine, type: :model do
  # let(:client) { create :client }
  # let(:must_be_female) { create :female }
  # let(:eighteen_plus) { create :eighteen_plus }
  # let(:requirement) { create :requirement, rule: eighteen_plus, positive: true }
  # let(:program) { create :program, requirements: [requirement] }
  # let(:sub_program) { create :sub_program, program: program }
  # let(:voucher) { create :voucher, sub_program: sub_program }
  # let(:opportunity) { create :opportunity, voucher: voucher }
  
  describe "engine_modes" do
    it 'contains VI-SPDAT Priority Score' do
      expect( Matching::Engine.engine_modes.keys ).to include "VI-SPDAT Priority Score"
    end
  end

  # describe "engine runs" do
  #   it 'and does not throw an error' do
  #     expect { 
  #       opp_id = opportunity.id
  #       client_id = client.id
  #       # HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.6 Gender
  #       {
  #         0 => 'Female',
  #         1 => 'Male',
  #         2 => 'Transgender male to female',
  #         3 => 'Transgender female to male',
  #         4 => 'Doesn’t identify as male, female, or transgender',
  #         8 => 'Client doesn’t know',
  #         9 => 'Client refused',
  #         99 => 'Data not collected'
  #       }.each do |id, name|
  #         Gender.create! do |r|
  #           r.numeric = id
  #           r.text = name
  #         end
  #       end
  #       puts Opportunity.first.inspect
  #       Matching::RunEngineJob.perform_now 
  #       puts Matching::Engine.available_opportunities.count
  #       puts Matching::Engine.available_client_count
  #       engine = Matching::Engine.new(Matching::Engine.available_clients, Matching::Engine.available_opportunities)
  #       puts engine.clients_for_matches(opportunity).inspect
  #       # puts Opportunity.first.inspect
  #       # puts Client.first.inspect
  #       # puts opportunity.client_opportunity_matches.inspect
  #       # puts requirement.name
  #       # puts ClientOpportunityMatch.count
  #       # puts client.gender.inspect
  #     }.to_not raise_error
      
  #   end
  # end

end
