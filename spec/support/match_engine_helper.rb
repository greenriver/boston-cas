module MatchEngineHelper
  
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

    funding_source = generate_funding_source
    @funding_sources << funding_source.id
    subgrantee = generate_subgrantee requirements
    @subgrantees << subgrantee.id
    program = generate_program funding_source
    @programs << program.id
    sub_program = generate_sub_program program, subgrantee
    @sub_programs << sub_program.id
    voucher = generate_available_voucher sub_program
    @vouchers << voucher.id
    opportunity = generate_avaialable_voucher_based_opportunity voucher
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
  
  #Match Engine Factory 
  def generate_client_veteran
    Client.create(veteran: true)
  end

  def generate_client_gender_male
    Client.create(gender_id: 1)
  end

  def generate_client_gender_female
    Client.create(gender_id: 0)
  end

  def generate_client_gender_transgender
    Client.create(gender_id: [2,3].sample)
  end

  def generate_client_gender_unknown
    Client.create(gender_id: [4,8,9,99].sample)
  end

  def generate_client_with_birthday dob
    Client.create(date_of_birth: dob)
  end

  def generate_client_with_income income
    Client.create(income_total_monthly: income)
  end

  def generate_client_chronic_homeless_no_substance_abuse_veteran_mental_health
    Client.create(chronic_homeless: true, substance_abuse_problem: false, veteran: true, mental_health_problem: true)
  end

  def generate_client_homeless_chronic_co_morbid_with_start_date first_night_homeless
    Client.create(available: true, chronic_homeless: true, substance_abuse_problem: true, mental_health_problem: true, calculated_first_homeless_night: first_night_homeless)
  end

  def generate_client_homeless_physical_disability_male_chronic
    Client.create(available: true, chronic_homeless: true, physical_disability: true, gender_id: 1)
  end

  def generate_funding_source requirements = []
    FundingSource.create(requirements: requirements)
  end

  def generate_subgrantee requirements = []
    Subgrantee.create(name: '__test', requirements: requirements)
  end

  def generate_service_provider requirements = [], services = []
    Subgrantee.create(name: '__test', requirements: requirements)
  end

  def generate_program funding_source, requirements = [], services = []
    Program.create(name: '__test', funding_source: funding_source, requirements: requirements, services: services)
  end

  def generate_sub_program program, service_provider, sub_contractor = nil
    SubProgram.create(program: program, service_provider: service_provider, sub_contractor: sub_contractor)
  end

  def generate_available_voucher sub_program
    Voucher.create(sub_program: sub_program, available: true)
  end

  def generate_available_voucher_based_opportunity voucher
    Opportunity.create(voucher: voucher, available: true, available_candidate: true)
  end

  def make_clients
    @clients = []
    5.times {
      @clients << generate_client_veteran.id
    }
    @clients << generate_client_gender_male.id
    4.times {
      @clients << generate_client_gender_female.id
    }
    3.times {
      @clients << generate_client_gender_transgender.id
    }
    2.times {
      @clients << generate_client_gender_unknown.id
    }
    1.times {
      @clients << generate_client_with_birthday(Date.today - 12.years).id #lt 16 years
      @clients << generate_client_with_birthday(Date.today - 17.years).id #gt 16 years
      @clients << generate_client_with_birthday(Date.today - 26.years).id #gt 25 years
      @clients << generate_client_with_birthday(Date.today - 56.years).id #gt 55 years
      @clients << generate_client_with_birthday(Date.today - 61.years).id #gt 60 years
      @clients << generate_client_with_birthday(Date.today - 63.years).id #gt 62 years
    }
    4.times {
      @clients << generate_client_with_income(rand(10..1716)).id # < 30% AMI
    }
    7.times {
      @clients << generate_client_with_income(rand(1725..2833)).id # < 50% AMI
    }
    3.times {
      @clients << generate_client_with_income(rand(2900..3400)).id # < 60% AMI
    }
    2.times {
      @clients << generate_client_with_income(rand(3500..4260)).id # < 80% AMI
    }
    5.times {
      @clients << generate_client_with_income(rand(5500..6260)).id # > 80% AMI
    }
    8.times {
      @clients << generate_client_chronic_homeless_no_substance_abuse_veteran_mental_health.id
    }
    1.times {
      @clients << generate_client_homeless_physical_disability_male_chronic.id
    }
    dates = [
      Date.today - 8.years,
      Date.today - 5.days,
      Date.today - 10.years,
      Date.today - 18.months,
    ]
    dates.each do |d|
      @clients << generate_client_homeless_chronic_co_morbid_with_start_date(d).id
    end
    @clients
  end
end
