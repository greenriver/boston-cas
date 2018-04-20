require 'rails_helper'
require 'support/match_engine_helper'

RSpec.configure do |c|
  c.include MatchEngineHelper
end

RSpec.describe "Running the match engine...", type: :request do  
  let!(:female_clients) { create_list :client, 10, gender_id: 0 }
  let!(:male_clients) { create_list :client, 10, gender_id: 1 }
  let!(:unknown_gender_clients) { create_list :client, 10, gender_id: nil }
  let!(:female_veteran_clients) { create_list :client, 5, gender_id: 0, veteran: 1 }
  let!(:male_veteran_clients) { create_list :client, 3, gender_id: 1, veteran: 1 }
  let!(:ami_less_than_50_clients) { create_list :client, 9, gender_id: 1, veteran: 0, income_total_monthly: 40 }
  
  let!(:funding_source) { create  :funding_source}
  let!(:subgrantee) { create :subgrantee }
  
  def create_matches(rule)  
    requirements = [Requirement.new(rule: rule, positive: true)]
    
    program = create :program, funding_source: funding_source, requirements: requirements  
    sub_program = create :sub_program, program: program, service_provider: subgrantee
    voucher = create :voucher, sub_program: sub_program
    opportunity = create :opportunity, voucher: voucher
    Matching::Engine.new(Client.all, Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)    
  end

  #opportunity tests
  describe "with a female requirement from program" do 
    let!(:matches) { create_matches( create :female ) }
    
    it "matches all female clients" do 
      expected_ids = (female_clients.map(&:id) + female_veteran_clients.map(&:id)).sort
      expect(matches.pluck(:id).sort).to eq(expected_ids)
    end
  end
  
  describe "with veteran requirement from subgrantee" do 
    let!(:matches) { create_matches( create :veteran ) }
  
    it "matches all veteran clients" do
      expected_ids = (male_veteran_clients.map(&:id) + female_veteran_clients.map(&:id)).sort
      expect(matches.pluck(:id).sort).to eq(expected_ids)
    end
  end
  
  # describe "with sub 50 percent ami from service on program" do     
  #   let!(:matches) { create_matches( create :very_low_income ) }
  # 
  #   it "matches all sub 50 percent ami clients" do 
  #     binding.pry
  #     expected_ids = (ami_less_than_50_clients.map(&:id)).sort
  #     expect(matches.pluck(:id).sort).to eq(expected_ids)
  #   end
  # end
end
