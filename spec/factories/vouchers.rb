FactoryBot.define do
  factory :voucher, class: 'Voucher' do
    available { true }
    sub_program
  end
end
