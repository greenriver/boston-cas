require 'rails_helper'
require 'support/match_engine_helper'

RSpec.configure do |c|
  c.include MatchEngineHelper
end

RSpec.describe "Running the match engine...", type: :request do 
   
  let!(:female_clients) { create_list :client, 2, gender_id: 0 }
  let!(:male_clients) { create_list :client, 8, gender_id: 1 }
  let!(:unknown_gender_clients) { create_list :client, 7, gender_id: nil }
  let!(:female_veteran_clients) { create_list :client, 5, gender_id: 0, veteran: 1 }
  let!(:male_veteran_clients) { create_list :client, 3, gender_id: 1, veteran: 1 }
  let!(:ami_50_percent_clients) { create_list :client, 5, gender_id: 1, veteran: 0, income_total_monthly: 66600 / 2 }
  let!(:ami_100_percent_clients) { create_list :client, 5, gender_id: 1, veteran: 0, income_total_monthly: 66600 }
  let!(:age_10_clients) { create_list :client, 8, date_of_birth: Date.today - 10.years }
  let!(:age_16_clients) { create_list :client, 1, date_of_birth: Date.today - 16.years }
  let!(:age_18_clients) { create_list :client, 3, date_of_birth: Date.today - 18.years }
  let!(:age_25_clients) { create_list :client, 2, date_of_birth: Date.today - 16.years }
  let!(:age_30_clients) { create_list :client, 1, date_of_birth: Date.today - 30.years }
  let!(:veteran_chronic_substance_abuse_mental_clients) { create_list :client, 3, chronic_homeless: true, substance_abuse_problem: false, veteran: true, mental_health_problem: true }
  let!(:veteran_chronic_homeless_mental_health_clients) { create_list :client, 2, chronic_homeless: true, substance_abuse_problem: false, veteran: true, mental_health_problem: true }
  let!(:veteran_chronic_homeless_substance_abuse_mental_clients) { create_list :client, 1, chronic_homeless: true, substance_abuse_problem: true, veteran: true, mental_health_problem: true }
  let!(:mental_healthclients) { create_list :client, 5, chronic_homeless: false, substance_abuse_problem: false, veteran: false, mental_health_problem: true }
  
  
  let!(:funding_source) { create :funding_source}
  let!(:subgrantee) { create :subgrantee }
  
  def create_matches(*rules)  
    requirements = rules.map { |rule| Requirement.new(rule: rule, positive: true) }
    
    program = create :program, funding_source: funding_source, requirements: requirements 
    sub_program = create :sub_program, program: program, service_provider: subgrantee
    voucher = create :voucher, sub_program: sub_program
    opportunity = create :opportunity, voucher: voucher
    Matching::Engine.new(Client.all, Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)    
  end

  #opportunity tests
  describe "with a female requirement" do 
    let!(:matches) { create_matches( create :female ) }
    
    it "matches only female clients" do 
      expected_ids = (Client.where(gender_id: 0).map(&:id))
      expect(expected_ids).to include *matches.pluck(:id)
    end
    
  end
  
  describe "with veteran requirement" do 
    let!(:matches) { create_matches( create :veteran ) }
  
    it "matches only veteran clients" do
      expected_ids = (Client.where(veteran: true).map(&:id))
      expect(expected_ids).to include *matches.pluck(:id)
    end
  end
  
  describe "with sub 50 percent AMI" do     
    let!(:matches) { create_matches( create :very_low_income ) }
    
    it "matches only clients with income_total_monthly < AMI (Area Median Income)" do 
      very_low_income_clients = (Client.where("income_total_monthly < ?", 66600 * (0.5)).map(&:id))
      expect(very_low_income_clients).to include *matches.pluck(:id)
    end
  end
  
  # #NOT WORKING
  # describe "between 16 and 25 years old from funding source" do
  #   let(:sixteen) { Rule.where(type: Rules::AgeGreaterThanSixteen).first }
  #   let(:twenty_five)  { Rule.where(type: Rules::AgeGreaterThanTwentyFive).first }
  #   let(:requirements) { [Requirement.new(rule: sixteen, positive: true), Requirement.new(rule: twenty_five, positive: false)] }
  # 
  #   let!(:program) { create :program, funding_source: funding_source, requirements: requirements }  
  #   let!(:sub_program) { create :sub_program, program: program, service_provider: subgrantee }
  #   let!(:voucher) { create :voucher, sub_program: sub_program }
  #   let!(:opportunity) { create :opportunity, voucher: voucher }
  #   let!(:matches) { Matching::Engine.new(Client.all, Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity) }   
  # 
  #   it "Matches only clients between 16 and 25" do 
  #     expected_ids = (Client.where("date_of_birth > ? AND date_of_birth < ?", Date.today - 16.years, Date.today - 25.years).map(&:id)
  #     puts matches.pluck(:id)
  #     expect(matches.pluck(:id)).to eq(expected_ids))
  #   end
  # end
  
  describe "with chronically homeless, NOT substance abuse problem, veteran, mental health problem requirement" do 
    let!(:opportunity) { opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service }
    let!(:matches) { Matching::Engine.new(Client.all, Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity) }
   
    it "matches only clients who are chronically homeless, do NOT have a substance abuse problem, are a veteran, and have a mental health problem" do 
      expected_ids = (Client.where(chronic_homeless: true, substance_abuse_problem: false, veteran: true, mental_health_problem: true).map(&:id))
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
  
  # #NOT WORKING
  # describe "with homeless, chronic_homeless, mental health, and substance abuse requirement" do
  #   # create an opportunity with a known set of requirements:
  #   # homeless, chronically homeless & MI & SA co-morbid
  #   # see that the clients that match are returned first homeless night asc
  # 
  #   #create_matches differs by not creating a service_provider and passing it to the sub_program. 
  #   #I don't know if this matters
  #   let!(:matches) { create_matches Rule.where(type: Rules::Homeless).first, Rule.where(type: Rules::ChronicallyHomeless).first, Rule.where(type: Rules::MiAndSaCoMorbid).first }
  # 
  #   # let!(homeless) { Requirement.new(rule: Rule.where(type: Rules::Homeless).first, positive: true) }
  #   # let!(chronic) { Requirement.new(rule: Rule.where(type: Rules::ChronicallyHomeless).first, positive: true) }
  #   # let!(co_morbid) { Requirement.new(rule: Rule.where(type: Rules::MiAndSaCoMorbid).first, positive: true) }
  #   # let!(requirements) { [homeless, chronic, co_morbid] }
  #   # 
  #   # let!(funding_source) { generate_funding_source }
  #   # let!(subgrantee) { generate_subgrantee }
  #   # let!(program) { generate_program funding_source, requirements }
  #   # let!(service_provider) { generate_service_provider }
  #   # let!(sub_program) { generate_sub_program program, subgrantee, service_provider }
  #   # let!(voucher) { generate_available_voucher sub_program }
  #   # let!(opportunity) { generate_avaialable_voucher_based_opportunity voucher }
  #   # let!(matches) { Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity) }
  # 
  #   it "matches in correct match client order" do
  #     top_match = matches[0]
  #     ten_years_ago = Date.today - 10.years
  #     expect(ten_years_ago).to eq top_match[:calculated_first_homeless_night]
  #   end  
  # end
end
