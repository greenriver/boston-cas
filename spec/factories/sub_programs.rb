###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :sub_program, class: 'SubProgram' do
    program_type { 'Sponsor-Based' }
    program
  end
end
