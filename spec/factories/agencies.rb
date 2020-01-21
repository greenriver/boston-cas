FactoryBot.define do
  factory :agency, class: 'Agency' do
    sequence(:name) {|n| "Agency #{n}" }
  end
end
