FactoryGirl.define do
  factory :project_a, class: 'Warehouse::Project' do
    ProjectName "Project A"
  end
  factory :project_b, class: 'Warehouse::Project' do
    ProjectName "Project B"
  end
end