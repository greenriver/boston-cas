FactoryBot.define do
  factory :program, class: 'Program' do
    name { 'Test Program' }
    match_route { MatchRoutes::Default.first }
  end
end
