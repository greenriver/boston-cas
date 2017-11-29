FactoryGirl.define do
  factory :male_gender, class: "Gender" do
    numeric 1
    text 'Male'
  end
  factory :female_gender, class: "Gender" do
    numeric 0
    text 'Female'
  end
  factory :trans_mf_gender, class: "Gender" do
    numeric 2
    text 'Transgender male to female'
  end
  factory :trans_fm_gender, class: "Gender" do
    numeric 3
    text 'Transgender female to male'
  end
end
