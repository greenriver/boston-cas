###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :match_decisions_hsa_accepts_client, class: 'MatchDecisions::ProviderOnly::HsaAcceptsClient' do
    status { :declined }
    association :decline_reason, factory: :hsa_decline_reason
  end
end