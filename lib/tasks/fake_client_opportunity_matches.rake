namespace :fake_client_opportunity_matches do
  desc "Generate between 2 and 5 client matches for a random 10 clients"
  task g_matches: :environment do

    @clients = Client.ids

    @open_opps = Opportunity.where(available: true)
    @client_opp = @open_opps.ids


    (@clients.sample(10)).map do |to_match|
      (@client_opp.sample(5)).map do |opp|
        ClientOpportunityMatch.create!(
          score: Faker::Number.between(25, 100),
          client_id: to_match,
          opportunity_id: opp,
          proposed_at: Faker::Date.between(45.days.ago, 30.days.ago)
          )
      end
    end

    @to_notifications = ClientOpportunityMatch.ids

    @to_notifications.map do |n|
      5.times do |i|
        [Notifications::Base,Notifications::B].sample.create!(
          recipient: ['DND','HSA','Shelter Agency','HSW','Client','Housing Owner','CORI'].sample,
          response: ['Sent','Accepted','Declined','Expired'].sample,
          client_opportunity_match_id: n,
          updated_at: Faker::Date.between(29.days.ago, Date.current)
        )
      end
    end

  end
end
