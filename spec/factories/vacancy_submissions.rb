FactoryBot.define do
  factory :vacancy_submission do
    association :user
    status { 'awaiting_approval' }

    transient do
      the_program    { create(:program) }
      the_sub_program { create(:sub_program, program: the_program, program_type: 'Project-Based', building: create(:building)) }
      is_voucher     { false }
    end

    draft_data do
      data = {
        'program_id'     => the_program.id,
        'sub_program_id' => the_sub_program.id,
        'resource_type'  => 'PSH Resource',
        'is_voucher'     => is_voucher,
      }
      unless is_voucher
        data.merge!(
          'unit_address_street'      => '123 Main St',
          'unit_address_unit_number' => '1A',
          'unit_address_city'        => 'Boston',
          'unit_address_state'       => 'MA',
          'unit_address_zip'         => '02101',
        )
      end
      data
    end

    trait :voucher do
      is_voucher { true }
      transient do
        the_sub_program { create(:sub_program, program: the_program, program_type: 'Tenant-Based') }
      end
    end

    trait :changes_requested do
      status { 'return_changes_requested' }
    end

    trait :active do
      status { 'active' }
    end
  end
end
