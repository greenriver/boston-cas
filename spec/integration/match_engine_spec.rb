require 'rails_helper'

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
  let!(:mental_health_clients) { create_list :client, 5, chronic_homeless: false, substance_abuse_problem: false, veteran: false, mental_health_problem: true }
  let!(:physically_disabled_clients) { create_list :client, 3, physical_disability: true }
  let!(:physically_disabled_not_homeless_clients) { create_list :client, 3, physical_disability:true, available: false }
  let!(:physically_disabled_male_clients) { create_list :client, 2, physical_disability: true, gender_id: 1 }
  let!(:physically_disabled_male_chronic_clients) { create_list :client, 2, physical_disability: true, gender_id: 1, chronic_homeless: true }
  let!(:physically_disabled_male_not_chronic_clients) { create_list :client, 2, physical_disability: true, gender_id: 1, chronic_homeless: false }
  
  let!(:funding_source) { create :funding_source}
  let!(:subgrantee) { create :subgrantee }
  
  def create_matches(*rules)
    #Pass in any number of hashes that look like {rule: rule, positive: true}  
    requirements = rules.map { |rule| Requirement.new(rule: rule[:rule], positive: rule[:positive]) }
    
    program = create :program, funding_source: funding_source, requirements: requirements 
    sub_program = create :sub_program, program: program, service_provider: subgrantee
    voucher = create :voucher, sub_program: sub_program
    opportunity = create :opportunity, voucher: voucher
    Matching::Engine.new(Client.all, Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)    
  end

  #opportunity tests
  describe "with female requirement" do 
    let!(:matches) { create_matches( {rule: create(:female), positive: true} ) }
    
    it "matches only female clients" do 
      expected_ids = Client.where(gender_id: 0).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end
    
  end
  
  describe "with veteran requirement" do 
    let!(:matches) { create_matches( {rule: create(:veteran), positive: true} ) }
  
    it "matches only veteran clients" do
      expected_ids = Client.where(veteran: true).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end
  end
  
  describe "with sub 50 percent AMI requirement" do     
    let!(:matches) { create_matches( {rule: create(:income_less_than_50_percent_ami), positive: true} ) }
  
    it "matches only clients with income_total_monthly < AMI (Area Median Income) * 50%" do 
      expected_ids = Client.where("income_total_monthly < ?", Config.get(:ami) * (0.5)).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end
  end
  
  describe "between 16 and 25 years old" do
    let!(:matches) { create_matches( 
      {rule: create(:sixteen_plus), positive: true}, 
      {rule: create(:twenty_five_plus), positive: false},
      ) }
  
    it "Matches only clients between 16 and 25 years old" do 
      expected_ids = Client.where("date_of_birth < ? AND date_of_birth > ?", Date.today - 16.years, Date.today - 25.years).map(&:id)
      expect(matches.pluck(:id)).to match_array(expected_ids)
    end
  end
  
  describe "with chronically homeless, NOT substance abuse problem, veteran, mental health problem requirement" do 
    let!(:matches) { create_matches( 
      {rule: create(:veteran), positive: true}, 
      {rule: create(:chronic_substance_use), positive: false},
      {rule: create(:chronically_homeless), positive: true},
      {rule: create(:mental_health_eligible), positive: true}, 
      ) }
    
    it "matches only clients who are chronically homeless, do NOT have a substance abuse problem, are a veteran, and have a mental health problem" do 
      expected_ids = Client.where(chronic_homeless: true, substance_abuse_problem: false, veteran: true, mental_health_problem: true).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
  
  # #NOT WORKING
  # describe "with homeless, chronic_homeless, mental health, and substance abuse requirement" do  
  #   #create_matches differs by not creating a service_provider and passing it to the sub_program. 
  #   #I don't know if this matters
  #   let!(:matches) { create_matches( 
  #     {rule: create(:homeless), positive: true}, 
  #     {rule: create(:chronically_homeless), positive: true},
  #     {rule: create(:mi_and_sa_co_morbid), positive: true},
  #     ) }
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
  #   it "clients that match are returned first homeless night asc" do
  #     top_match = matches[0]
  #     ten_years_ago = Date.today - 10.years
  #     expect(ten_years_ago).to eq top_match[:calculated_first_homeless_night]
  #   end  
  # end
  
  describe "without physical disability requirement" do 
    let!(:matches) { create_matches ( {rule: create(:physical_disability), positive: false} ) }
    
    it "matches only clients who do not have a physical disability" do 
      expected_ids = Client.where(physical_disability: false).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
  
  describe "with physical disability and homeless requirement" do 
    let!(:matches) { create_matches( 
      {rule: create(:physical_disability), positive: true},
      {rule: create(:homeless), positive: true}
      ) }
  
    it "matches only clients who have a physical disability and are homeless" do 
      expected_ids = Client.where(physical_disability: true, available: true).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
  
  describe "with physical disability and is male and homeless requirement" do 
    let!(:matches) { create_matches( 
      {rule: create(:physical_disability), positive: true},
      {rule: create(:homeless), positive: true},
      {rule: create(:male), positive: true}
      ) }
  
    it "matches only clients who have a physical disability and are homeless and male" do 
      expected_ids = Client.where(physical_disability: true, available: true, gender_id: 1).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
  
  describe "with physical disability and is male, homeless, and chronically homeless requirement" do 
    let!(:matches) { create_matches( 
      {rule: create(:physical_disability), positive: true},
      {rule: create(:homeless), positive: true},
      {rule: create(:male), positive: true},
      {rule: create(:chronically_homeless), positive: true},
      ) }
  
    it "matches only clients who have a physical disability and are male, homeless, and chronically homeless" do 
      expected_ids = Client.where(physical_disability: true, available: true, chronic_homeless: true, gender_id: 1).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end  
  end
end
