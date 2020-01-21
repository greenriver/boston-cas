FactoryBot.define do
  factory :match_note, class: 'MatchEvents::Note' do
    note { 'A note' }
    admin_note { false }
  end
  factory :admin_note, class: 'MatchEvents::Note' do
    note { 'A note' }
    admin_note { true }
  end
end