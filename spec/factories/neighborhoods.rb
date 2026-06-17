###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :neighborhood_cambridge, class: 'Neighborhood' do
    name { 'Cambridge' }
  end
  factory :neighborhood_beacon_hill, class: 'Neighborhood' do
    name { 'Beacon Hill' }
  end
end