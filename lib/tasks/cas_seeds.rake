namespace :cas_seeds do

  # The tasks in this file are to seed the CAS db with fake data for development.

  desc 'Run all cas seed tasks'
  task all: %i{
    create_opportunities
    create_rules
    create_services
    ensure_all_users_have_contacts
    create_match_decision_reasons
  }
  
  desc 'create fake opportunities'
  task create_opportunities: [:environment, "log:info_to_stdout"] do
    CasSeeds::Opportunities.new.run!
  end
  
  desc 'create rules'
  task create_rules: [:environment, "log:info_to_stdout"] do
    CasSeeds::Rules.new.run!
  end

  desc 'create services'
  task create_services: [:environment, "log:info_to_stdout"] do
    CasSeeds::Services.new.run!
  end

  desc 'create match decision reasons'
  task create_match_decision_reasons: :environment do
    CasSeeds::MatchDecisionReasons.new.run!
  end

  desc 'import vouchers'
  task import_vouchers: [:environment, "log:info_to_stdout"] do
    CasSeeds::Vouchers.new.run!
  end

  desc 'import chronically homeless project clients for mvp'
  task import_chronically_homeless_from_csv: [:environment, "log:info_to_stdout"] do
    CasSeeds::ChronicallyHomeless.new.run!
  end

  # TODO: delete this?  I don't think we'll need it anymore
  desc 'ensure all users have contacts'
  task ensure_all_users_have_contacts: [:environment, "log:info_to_stdout"] do
    
    user_ids_to_exclude = Contact.pluck('DISTINCT user_id')
    
    users = User.where.not(id: user_ids_to_exclude)
    puts "Creating missing contact records for #{users.count} users."

    users.find_each do |user|
      user.build_contact
      user.contact.first_name = user.first_name
      user.contact.last_name = user.last_name
      user.contact.email = user.email
      user.contact.save
    end
    
  end

  desc 'ensure all match routes exist'
  task ensure_all_match_routes_exist: [:environment, "log:info_to_stdout"] do
    MatchRoutes::Base.ensure_all
  end

  desc 'ensure all match prioritization schemes exist'
  task ensure_all_match_prioritization_schemes_exist: [:environment, "log:info_to_stdout"] do
    MatchPrioritization::Base.ensure_all
  end

  # These have been disabled because they create fake data for development mode
  # we could potentially bring them back as part of a dev-mode only script

  # desc 'add a regular contact to all clients'
  # task add_regular_contact_to_all_clients: [:environment, "log:info_to_stdout"] do
  #   CasSeeds::ClientRegularContact.new.run!
  # end
  
  # desc 'add a shelter agency contact to all clients'
  # task add_shelter_agency_contact_to_all_clients: [:environment, "log:info_to_stdout"] do
  #   CasSeeds::ClientShelterAgencyContact.new.run!
  # end

  # desc 'add a housing subsidy administrator to all opportunities'
  # task add_housing_subsidy_admin_to_all_opportunities: [:environment, "log:info_to_stdout"] do
  #   CasSeeds::OpportunityHousingSubsidyAdminContact.new.run!
  # end

end