require 'test_helper'
require 'support/match_engine_factory'
# run with: 
# bin/rake test TEST="test/data_integration/rule_test.rb"

class RuleTest < ActiveSupport::TestCase
  
  def setup
    @m = MatchEngineFactory.new
    @clients = @m.make_clients
    
  end

  def teardown

  end

  # Rules Tests
  def test_rule_veteran_match_count  
    rule = Rule.where(type: Rules::Veteran).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))
    # 5 directly + 8 from test_opportunity_voucher_based_rules_on_program_service_provider_subgrantee_funding_source_service
    assert_equal 13, matches.count
  end

  def test_rule_male_match_count  
    rule = Rule.where(type: Rules::Male).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    assert_equal 2, matches.count
  end

  def test_rule_female_match_count  
    rule = Rule.where(type: Rules::Female).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    assert_equal 4, matches.count
  end

  def test_rule_transgender_match_count  
    rule = Rule.where(type: Rules::Transgender).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    assert_equal 3, matches.count
  end

  def test_rule_less_than_16_years_old_match_count  
    rule = Rule.where(type: Rules::AgeGreaterThanSixteen).first_or_create
    requirement = Requirement.new(rule: rule, positive: false)
    matches = requirement.clients_that_fit(Client.where(id: @clients))
    assert_equal 1, matches.count
  end

  def test_rule_older_than_55_years_old_match_count  
    rule = Rule.where(type: Rules::AgeGreaterThanFiftyFive).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))
    assert_equal 3, matches.count
  end

  def test_rule_55_and_62_years_old_match_count  
    rule = Rule.where(type: Rules::AgeGreaterThanFiftyFive).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    rule = Rule.where(type: Rules::AgeGreaterThanSixtyTwo).first_or_create
    requirement = Requirement.new(rule: rule, positive: false)
    matches = requirement.clients_that_fit(matches)
    
    assert_equal 2, matches.count
  end

  def test_rule_income_less_than_30_percent_ami_match_count  
    rule = Rule.where(type: Rules::IncomeLessThanThirtyPercentAmi).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    assert_equal 4, matches.count
  end

  def test_rule_income_between_50_and_80_percent_ami_match_count  
    rule = Rule.where(type: Rules::IncomeLessThanFiftyPercentAmi).first_or_create
    requirement = Requirement.new(rule: rule, positive: false)
    matches = requirement.clients_that_fit(Client.where(id: @clients))

    rule = Rule.where(type: Rules::IncomeLessThanEightyPercentAmi).first_or_create
    requirement = Requirement.new(rule: rule, positive: true)
    matches = requirement.clients_that_fit(matches)

    assert_equal 5, matches.count
  end


  private
    
end

