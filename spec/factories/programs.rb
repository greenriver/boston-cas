###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :program, class: 'Program' do
    name { 'Test Program' }
    match_route { MatchRoutes::Default.first }
  end
end
