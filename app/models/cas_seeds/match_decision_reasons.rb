###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class MatchDecisionReasons
    CLIENT_REJECTED = 2
    PROVIDER_REJECTED = 3

    # When adding new decline or cancel reasons to CAS, add them here, and indicate the rejection type for CE APR reporting.
    # Then in the appropriate route or step, add to step_cancel_reasons or step_decline_reasons
    ALL_REASONS = [
      ['Additional screening criteria imposed by third parties', PROVIDER_REJECTED],
      ['Barred from working with agency', PROVIDER_REJECTED],
      ['Client deceased', CLIENT_REJECTED],
      ['Client has another housing option', CLIENT_REJECTED],
      ['Client has declined match', CLIENT_REJECTED],
      ['Client has disappeared', CLIENT_REJECTED],
      ['Client has disengaged', CLIENT_REJECTED],
      ['Client needs higher level of care', PROVIDER_REJECTED],
      ['Client no longer eligible for match', PROVIDER_REJECTED],
      ['Client received another housing opportunity', CLIENT_REJECTED],
      ['Client receiving navigation services', nil],
      ['Client refused offer', CLIENT_REJECTED],
      ['Client refused unit (non-SRO)', CLIENT_REJECTED],
      ['Client refused voucher', CLIENT_REJECTED],
      ['Client is already receiving navigation services', CLIENT_REJECTED],
      ["Client won't be eligible based on funding source", PROVIDER_REJECTED],
      ["Client won't be eligible for housing type", PROVIDER_REJECTED],
      ["Client won't be eligible for services", PROVIDER_REJECTED],
      ['CORI', PROVIDER_REJECTED],
      ['Does not agree to services', CLIENT_REJECTED],
      ['Does not want housing at this time', CLIENT_REJECTED],
      ['Don’t know / disappeared', nil],
      ['Falsification of documents', PROVIDER_REJECTED],
      ['Health and Safety', PROVIDER_REJECTED],
      ['Hospitalized', nil],
      ['Household became disengaged', nil],
      ['Household could not be located', PROVIDER_REJECTED],
      ['Household did not respond after initial acceptance of match', PROVIDER_REJECTED],
      ['Housing Case Manager has disengaged', PROVIDER_REJECTED],
      ['HSP CORI', PROVIDER_REJECTED],
      ['Immigration status', PROVIDER_REJECTED],
      ['In Treatment/Recovery Center', CLIENT_REJECTED],
      ['Incarcerated', CLIENT_REJECTED],
      ['Institutionalized', CLIENT_REJECTED],
      ['Ineligible for Housing Program', PROVIDER_REJECTED],
      ['Match expired – Agency interaction', nil],
      ['Match expired – No agency interaction', PROVIDER_REJECTED],
      ['Match expired – No Housing Case Manager interaction', PROVIDER_REJECTED],
      ['Match expired – No Shelter Agency interaction', PROVIDER_REJECTED],
      ['Match expired', nil],
      ['Match stalled - Agency has disengaged', PROVIDER_REJECTED],
      ['Match stalled – Housing Case Manager has disengaged', PROVIDER_REJECTED],
      ['Mitigation failed', nil],
      ['Self-resolved', CLIENT_REJECTED],
      ['Shelter Agency has disengaged', PROVIDER_REJECTED],
      ['SORI', PROVIDER_REJECTED],
      ['SSP CORI', PROVIDER_REJECTED],
      ['Unable to reach client after multiple attempts', PROVIDER_REJECTED],
      ['Unsafe environment for this person', CLIENT_REJECTED],
      ['Unwilling to live in SRO', CLIENT_REJECTED],
      ['Unwilling to live in that neighborhood', CLIENT_REJECTED],
      ['Vacancy filled by other client', PROVIDER_REJECTED],
      ['Vacancy should not have been entered', nil],
      ['Other', nil],
    ].freeze

    def run!
      ALL_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::Base.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end
  end
end
