FactoryGirl.define do
  factory :cohort_a, class: 'Warehouse::Cohort' do
    name "Cohort A"
    active_cohort true
    visible_in_cas true
  end
  factory :cohort_b, class: 'Warehouse::Cohort' do
    name "Cohort B"
    active_cohort true
    visible_in_cas true
  end
end