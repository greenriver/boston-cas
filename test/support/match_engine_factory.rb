#require 'test_helper'

class MatchEngineFactory
  
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

  def generate_avaialable_voucher_based_opportunity voucher
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
