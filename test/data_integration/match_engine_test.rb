require 'test_helper'
require 'support/match_engine_factory'
# run with: 
# bin/rake test TEST="test/data_integration/match_engine_test.rb"

class MatchEngineTest < ActiveSupport::TestCase
  
  def setup
    @m = MatchEngineFactory.new
    @clients = @m.make_clients
    make_funding_sources
    make_subgrantees
    make_programs
    make_sub_programs
    make_service_providers
    make_vouchers
    make_opportunities
    make_units
    make_buildings
    make_opportunities_for_priority_test
  end

  def teardown
    destroy_clients
    destroy_vouchers
    destroy_sub_programs
    destroy_programs
    destroy_funding_sources
    destroy_subgrantees
    destroy_units
    destroy_buildings
    destroy_opportunities
    destroy_opportunities_for_priority_test
  end

  # Opportunity Tests
  def test_opportunity_voucher_based_female_only_from_program
    rule = Rule.where(type: Rules::Female).first
    requirements = [Requirement.new(rule: rule, positive: true)]

    funding_source = @m.generate_funding_source
    @funding_sources << funding_source.id
    subgrantee = @m.generate_subgrantee
    @subgrantees << subgrantee.id
    program = @m.generate_program funding_source, requirements
    @programs << program.id
    sub_program = @m.generate_sub_program program, subgrantee
    @sub_programs << sub_program.id
    voucher = @m.generate_available_voucher sub_program
    @vouchers << voucher.id
    opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
    @opportunities << opportunity.id
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)
    
    assert_equal 4, matches.count
  end

  def test_opportunity_voucher_based_veteran_only_from_subgrantee
    opportunity = opportunity_voucher_based_veteran_only_from_subgrantee
    
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)

    # 5 directly + 8 from test_opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
    assert_equal 13, matches.count
  end

  def test_opportunity_voucher_based_sub_50_percent_ami_from_service_on_program    
    funding_source = @m.generate_funding_source
    @funding_sources << funding_source.id
    rule = Rule.where(type: Rules::IncomeLessThanFiftyPercentAmi).first
    requirements = [Requirement.new(rule: rule, positive: true)]
    services = [Service.new(name: '__test__', requirements: requirements)]

    subgrantee = @m.generate_subgrantee
    @subgrantees << subgrantee.id
    program = @m.generate_program funding_source, [], services
    @programs << program.id
    sub_program = @m.generate_sub_program program, subgrantee
    @sub_programs << sub_program.id
    voucher = @m.generate_available_voucher sub_program
    @vouchers << voucher.id
    opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
    @opportunities << opportunity.id
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)
   
    assert_equal 11, matches.count
  end

  def test_opportunity_voucher_based_between_16_and_25_years_old_from_funding_source
    sixteen = Rule.where(type: Rules::AgeGreaterThanSixteen).first
    twenty_five = Rule.where(type: Rules::AgeGreaterThanTwentyFive).first
    requirements = [Requirement.new(rule: sixteen, positive: true), Requirement.new(rule: twenty_five, positive: false)]

    funding_source = @m.generate_funding_source requirements
    @funding_sources << funding_source.id
    subgrantee = @m.generate_subgrantee
    @subgrantees << subgrantee.id
    program = @m.generate_program funding_source
    @programs << program.id
    sub_program = @m.generate_sub_program program, subgrantee
    @sub_programs << sub_program.id
    voucher = @m.generate_available_voucher sub_program
    @vouchers << voucher.id
    opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
    @opportunities << opportunity.id
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)
    
    assert_equal 1, matches.count
  end

  def test_opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
    opportunity = opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
    
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)
   
    assert_equal 8, matches.count
  end

  def test_match_client_order
    # create an opportunity with a known set of requirements:
    # homeless, chronically homeless & MI & SA co-morbid
    # see that the clients that match are returned first homeless night asc
    homeless = Requirement.new(rule: Rule.where(type: Rules::Homeless).first, positive: true)
    chronic = Requirement.new(rule: Rule.where(type: Rules::ChronicallyHomeless).first, positive: true)
    co_morbid = Requirement.new(rule: Rule.where(type: Rules::MiAndSaCoMorbid).first, positive: true)
    requirements = [homeless, chronic, co_morbid]

    funding_source = @m.generate_funding_source
    @funding_sources << funding_source.id
    subgrantee = @m.generate_subgrantee
    @subgrantees << subgrantee.id
    program = @m.generate_program funding_source, requirements
    @programs << program.id
    service_provider = @m.generate_service_provider
    @service_providers << service_provider
    sub_program = @m.generate_sub_program program, subgrantee, service_provider
    @sub_programs << sub_program.id
    voucher = @m.generate_available_voucher sub_program
    @vouchers << voucher.id
    opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
    @opportunities << opportunity.id
    matches = Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).clients_for_matches(opportunity)
    top_match = matches[0]
    ten_years_ago = Date.today - 10.years

    assert_equal ten_years_ago, top_match[:calculated_first_homeless_night]
  end

  def test_matchability
    # create two opportunities, one obviously more restrictive than the other
    # more restrictive opportunity should have a smaller matchability score
    less_restrictive = opportunity_voucher_based_veteran_only_from_subgrantee
    more_restrictive = opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
    # Update matchability
    Matching::Matchability.update Opportunity.where(id: [less_restrictive.id, more_restrictive.id])
    less_restrictive.reload
    more_restrictive.reload

    assert less_restrictive.matchability > more_restrictive.matchability
  end

  def test_most_restrictive_opportunity_for_client_returned_first
    skip 'need to fixup test data to get varying matchabilities across different opportunities'
    # feed the engine one client with many opportunities, 
    # verify that the most restrictive opportunity that maches is returned first (lowest matchability), 
    # least restrictive last (highest matchability)
    
    # client - homeless + physical disability + male + chronic
    client = Client.where(available: true, chronic_homeless: true, physical_disability: true, gender_id: 1).first
    # opportunities:
    # 1. doesn't match: no physical disability
    # 2. matches, not very restrictive: homeless + physical disability
    # 3. matches, more restrictive: homeless + physical disability + male
    # 4. matches, very restrictive: homeless + physical disability + male + chronic
    
    # Update matchability
    Matching::Matchability.update Opportunity.where(id: @restictive_opportunities)
    # generate matches
    Matching::Engine.new(Client.where(id: client.id), Opportunity.where(id: @restictive_opportunities)).create_candidates

    assert_equal client.prioritized_matches.first.opportunity.id, @most_restrictive.id
  end

  def test_least_restrictive_opportunity_for_client_returned_last
    skip 'This test may not be valid'
    # feed the engine one client with many opportunities, 
    # verify that the most restrictive opportunity that maches is returned first (lowest matchability), 
    # least restrictive last (highest matchability)
    
    # client - homeless + physical disability + male + chronic
    client = Client.where(available: true, chronic_homeless: true, physical_disability: true, gender_id: 1).first
    # opportunities:
    # 1. doesn't match: no physical disability
    # 2. matches, not very restrictive: homeless + physical disability
    # 3. matches, more restrictive: homeless + physical disability + male
    # 4. matches, very restrictive: homeless + physical disability + male + chronic
    
    # Update matchability
    Matching::Matchability.update Opportunity.where(id: @restictive_opportunities)
    # generate matches
    Matching::Engine.new(Client.where(id: client.id), Opportunity.where(id: @restictive_opportunities)).create_candidates
    client.prioritized_matches.each do |m|
      puts "#{@least_restrictive.id} #{m.id}"
    end

    assert_equal  @least_restrictive.reload.matchability, client.prioritized_matches.last.opportunity.matchability
  end

  def test_highest_priority_client_on_match_is_active_after_match
    skip 'client_first_homeless nights are nil which is messing up ordering'
    opportunity = opportunity_voucher_based_veteran_only_from_subgrantee
    
    Matching::Engine.new(Client.where(id: @clients), Opportunity.where(id: opportunity.id)).create_candidate_matches(opportunity)
    assert opportunity.prioritized_matches.first.active
  end

  private
    def make_funding_sources
      @funding_sources = []
    end
    
    def make_subgrantees
      @subgrantees = []
    end
    
    def make_programs
      @programs = []
    end
    
    def make_sub_programs
      @sub_programs = []
    end

    def make_service_providers
      @service_providers = []
    end
    
    def make_vouchers
      @vouchers = []
    end
    
    def make_opportunities
      @opportunities = []
    end

    def make_units
      @units = []
    end
    
    def make_buildings
      @buildings = []
    end

    def destroy_clients
      @clients.each do |c|
        Client.find(c).really_destroy!
      end
    end

    def destroy_opportunities
      @opportunities.each do |c|
        Opportunity.find(c).really_destroy!
      end
    end

    def destroy_vouchers
      @vouchers.each do |c|
        Voucher.find(c).destroy
      end
    end
    
    def destroy_sub_programs
      @sub_programs.each do |c|
        SubProgram.find(c).destroy
      end
    end

    def destroy_service_providers
      @service_providers.each do |c|
        Subgrantee.find(c).destroy
      end
    end

    def destroy_programs
      @programs.each do |c|
        Program.find(c).destroy
      end
    end

    def destroy_units
      @units.each do |c|
        Unit.find(c).really_destroy!
      end
    end

    def destroy_buildings
      @buildings.each do |c|
        Building.find(c).really_destroy!
      end
    end

    def destroy_subgrantees
      @subgrantees.each do |c|
        Subgrantee.find(c).destroy
      end
    end

    def destroy_funding_sources
      @funding_sources.each do |c|
        FundingSource.find(c).destroy
      end
    end

    def destroy_opportunities_for_priority_test
        Opportunity.where(id: @restictive_opportunities).each do |c|
          c.really_destroy!
        end
    end

    def opportunity_voucher_based_veteran_only_from_subgrantee
      rule = Rule.where(type: Rules::Veteran).first
      requirements = [Requirement.new(rule: rule, positive: true)]

      funding_source = @m.generate_funding_source
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee requirements
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source
      @programs << program.id
      sub_program = @m.generate_sub_program program, subgrantee
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end

    def opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
      veteran = [Requirement.new(rule: Rule.where(type: Rules::Veteran).first, positive: true)]
      no_substance_abuse = [Requirement.new(rule: Rule.where(type: Rules::ChronicSubstanceUse).first, positive: false)]
      chronic = [Requirement.new(rule: Rule.where(type: Rules::ChronicallyHomeless).first, positive: true)]
      mental_health = [Requirement.new(rule: Rule.where(type: Rules::MentalHealthEligible).first, positive: true)]
      services = [Service.new(name: '__test__', requirements: mental_health)]

      funding_source = @m.generate_funding_source veteran
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee no_substance_abuse
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source, chronic
      @programs << program.id
      service_provider = @m.generate_service_provider [], services
      @service_providers << service_provider
      sub_program = @m.generate_sub_program program, subgrantee, service_provider
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end
# 1. doesn't match: no physical disability
    # 2. matches, not very restrictive: homeless + physical disability
    # 3. matches, more restrictive: homeless + physical disability + male
    # 4. matches, very restrictive: homeless + physical disability + male + chronic
    def opportunity_voucher_based_no_physical_disability
      rule = Rule.where(type: Rules::PhysicalDisablingCondition).first
      requirements = [Requirement.new(rule: rule, positive: false)]

      funding_source = @m.generate_funding_source
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee requirements
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source
      @programs << program.id
      sub_program = @m.generate_sub_program program, subgrantee
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end

    def opportunity_voucher_based_physical_disability_and_homeless
      requirements = []
      rule = Rule.where(type: Rules::PhysicalDisablingCondition).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::Homeless).first
      requirements << Requirement.new(rule: rule, positive: true)

      funding_source = @m.generate_funding_source
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee requirements
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source
      @programs << program.id
      sub_program = @m.generate_sub_program program, subgrantee
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end

    def opportunity_voucher_based_physical_disability_and_homeless_and_male
      requirements = []
      rule = Rule.where(type: Rules::PhysicalDisablingCondition).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::Homeless).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::Male).first
      requirements << Requirement.new(rule: rule, positive: true)

      funding_source = @m.generate_funding_source
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee requirements
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source
      @programs << program.id
      sub_program = @m.generate_sub_program program, subgrantee
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end

    def opportunity_voucher_based_physical_disability_and_homeless_and_male_and_chronic
      requirements = []
      rule = Rule.where(type: Rules::PhysicalDisablingCondition).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::Homeless).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::Male).first
      requirements << Requirement.new(rule: rule, positive: true)
      rule = Rule.where(type: Rules::ChronicallyHomeless).first
      requirements << Requirement.new(rule: rule, positive: true)

      funding_source = @m.generate_funding_source
      @funding_sources << funding_source.id
      subgrantee = @m.generate_subgrantee requirements
      @subgrantees << subgrantee.id
      program = @m.generate_program funding_source
      @programs << program.id
      sub_program = @m.generate_sub_program program, subgrantee
      @sub_programs << sub_program.id
      voucher = @m.generate_available_voucher sub_program
      @vouchers << voucher.id
      opportunity = @m.generate_avaialable_voucher_based_opportunity voucher
      @opportunities << opportunity.id
      return opportunity
    end

    def make_opportunities_for_priority_test
      @least_restrictive = opportunity_voucher_based_physical_disability_and_homeless
      @most_restrictive = opportunity_voucher_based_physical_disability_and_homeless_and_male_and_chronic
      @restictive_opportunities = [
        opportunity_voucher_based_no_physical_disability.id,
        @least_restrictive.id,
        opportunity_voucher_based_physical_disability_and_homeless_and_male.id,
        @most_restrictive.id,
      ]
    end
end
