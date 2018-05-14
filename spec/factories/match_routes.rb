FactoryGirl.define do
  factory :default_route, class: 'MatchRoutes::Default' do
    active true
  end
  factory :provider_route, class: 'MatchRoutes::ProviderOnly' do
    active true
  end
end
