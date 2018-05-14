require 'rails_helper'

RSpec.describe "Running the match engine...", type: :request do 
  MatchRoutes::Base.ensure_all
  MatchPrioritization::Base.ensure_all
  let!(:female_clients) { create_list :client, 2, gender_id: 0 }
  let!(:male_clients) { create_list :client, 8, gender_id: 1 }
  let!(:unknown_gender_clients) { create_list :client, 7, gender_id: nil }
  let!(:female_veteran_clients) { create_list :client, 5, gender_id: 0, veteran: 1 }
  let!(:male_veteran_clients) { create_list :client, 3, gender_id: 1, veteran: 1 }
  let!(:ami_50_percent_clients) { create_list :client, 5, gender_id: 1, veteran: 0, income_total_monthly: Config.get(:ami)/ 2 }
  let!(:ami_100_percent_clients) { create_list :client, 5, gender_id: 1, veteran: 0, income_total_monthly: Config.get(:ami) }
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
  let(:priority) { MatchPrioritization::DaysHomelessLastThreeYears.first }
  let(:route) { 
    r = MatchRoutes::Default.first 
    r.update(match_prioritization_id: priority.id)
    r
    }
  
  
  def create_opportunity(*rules)
    #Pass in any number of hashes that look like {rule: rule, positive: true}  
    requirements = rules.map { |rule| Requirement.new(rule: rule[:rule], positive: rule[:positive]) }
    
    program = create :program, funding_source: funding_source, requirements: requirements, match_route: route
    sub_program = create :sub_program, program: program, service_provider: subgrantee
    voucher = create :voucher, sub_program: sub_program
    opportunity = create :opportunity, voucher: voucher 
  end
  
  def create_matches(*rules)
    #Pass in any number of hashes that look like {rule: rule, positive: true}  
    opportunity = create_opportunity(*rules)
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
  
  describe "with homeless, chronic_homeless, mental health, and substance abuse requirement" do     
    let!(:matches) { create_matches( 
      {rule: create(:homeless), positive: true}, 
      {rule: create(:chronically_homeless), positive: true},
      {rule: create(:mi_and_sa_co_morbid), positive: true},
      ) }
  
    it "clients that match are returned first homeless night asc" do
      first_night = Client.where(
        available: true, 
        chronic_homeless: true, 
        substance_abuse_problem: true, 
        mental_health_problem: true
      ).minimum(:calculated_first_homeless_night)
      top_match = matches[0]
  
      expect(first_night).to eq top_match[:calculated_first_homeless_night]
    end  
  end
  
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
  
  describe "with veteran, no chronic substance abuse, chronically homeless, and mental health requirement" do 
    let!(:matches) { create_matches( 
      {rule: create(:veteran), positive: true},
      {rule: create(:chronic_substance_use), positive: false},
      {rule: create(:chronically_homeless), positive: true},
      {rule: create(:mental_health_eligible), positive: true},
      ) }
        
    it "matches only clients who are veterans, chronically homeless, have a mental health problem, and do not have a chronic substance abuse problem" do 
      expected_ids = Client.where(veteran: true, substance_abuse_problem: false, chronic_homeless: true, mental_health_problem: true).map(&:id)
      expect(expected_ids).to include *matches.pluck(:id)
    end 
  end
  
  describe "when we create two opportunities, one obviously more restrictive than the other" do
    let!(:less_restrictive) { create_opportunity( 
      {rule: create(:veteran), positive: true},
      ) }
      
    let!(:more_restrictive) { create_opportunity( 
      {rule: create(:veteran), positive: true},
      {rule: create(:chronic_substance_use), positive: false},
      {rule: create(:chronically_homeless), positive: true},
      {rule: create(:mental_health_eligible), positive: true},
      ) }
    
    it "the more restrictive opportunity should have a smaller matchability score" do
      # Update matchability
      Matching::Matchability.update(Opportunity.where(id: [less_restrictive.id, more_restrictive.id]), match_route: route)
      less_restrictive.reload
      more_restrictive.reload
      
      expect(less_restrictive.matchability).to be > (more_restrictive.matchability)
    end
  end
  
  describe "when we feed the engine one client with many opportunities" do 
    # skip 'need to fixup test data to get varying matchabilities across different opportunities
    
    # client: - homeless + physical disability + male + chronic
    let!(:client) { Client.where(available: true, chronic_homeless: true, physical_disability: true, gender_id: 1).first } 
    
    # opportunities:
    # 1. doesn't match: no physical disability
    # 2. matches, not very restrictive: homeless + physical disability
    # 3. matches, more restrictive: homeless + physical disability + male
    # 4. matches, very restrictive: homeless + physical disability + male + chronic
    let!(:lots_of_clients) { create_list :client, 40, physical_disability: true }
    let!(:least_restrictive) { create_opportunity( 
      {rule: create(:physical_disability), positive: false},
    )}
    let!(:many_clients) { create_list :client, 30, physical_disability: true, available: true }
    let!(:less_restrictive) { create_opportunity( 
      {rule: create(:homeless), positive: true},
      {rule: create(:physical_disability), positive: true},
    )}
    let!(:some_clients) { create_list :client, 20, physical_disability: true, available: true, gender_id: 1 }
    let!(:more_restrictive) { create_opportunity( 
      {rule: create(:homeless), positive: true},
      {rule: create(:physical_disability), positive: true},
      {rule: create(:male), positive: true},
    )}
    let!(:a_few_clients) { create_list :client, 10, physical_disability: true, available: true, gender_id: 1, chronic_homeless: true }
    let!(:most_restrictive) { create_opportunity( 
      {rule: create(:homeless), positive: true},
      {rule: create(:physical_disability), positive: true},
      {rule: create(:male), positive: true},
      {rule: create(:chronically_homeless), positive: true},
    )}
    
    let!(:restrictive_opportunities) { [
      least_restrictive.id,
      less_restrictive.id,
      more_restrictive.id,  
      most_restrictive.id  
    ] }
    
    it "the most restrictive opportunity that matches is returned first (lowest matchability)" do
      # Update matchability
      Matching::Matchability.update(Opportunity.on_route(route).where(id: restrictive_opportunities), match_route: route)
      # generate matches
      Matching::Engine.new(Client.where(id: client.id), Opportunity.where(id: restrictive_opportunities)).create_candidates

      expect(client.prioritized_matches.first.opportunity.id).to eq(restrictive_opportunities.last)
    end
    
    it "the most restrictive opportunity that matches is activated" do
      # Update matchability
      Matching::Matchability.update(Opportunity.on_route(route).where(id: restrictive_opportunities), match_route: route)
      # generate matches
      Matching::Engine.new(Client.where(id: client.id), Opportunity.where(id: restrictive_opportunities)).create_candidates
      
      expect(client.prioritized_matches.first.active).to be true
    end
    
    it "least restrictive opportunity is returned last (highest matchability)" do
      # Update matchability
      Matching::Matchability.update(Opportunity.on_route(route).where(id: restrictive_opportunities), match_route: route)
      # generate matches
      Matching::Engine.new(Client.where(id: client.id), Opportunity.where(id: restrictive_opportunities)).create_candidates
    
      expect(client.prioritized_matches.last.opportunity.id).to eq(restrictive_opportunities[1])
    end
  end
end
