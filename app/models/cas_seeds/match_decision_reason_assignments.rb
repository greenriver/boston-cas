###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'csv'

module CasSeeds
  class MatchDecisionReasonAssignments
    # MatchDecisions::ApproveMatchHousingSubsidyAdmin used to have a hardcoded
    # step_decline_reasons(contact) override with two contact-dependent lists.
    # These are its audience-tagged equivalents, seeded once here so that
    # exception no longer needs to exist in Ruby.
    APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_DECISION_TYPE = 'MatchDecisions::ApproveMatchHousingSubsidyAdmin'

    APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_SHELTER_AGENCY_ONLY_REASONS = [
      'Client has another housing option',
      'Does not agree to services',
      'Unwilling to live in that neighborhood',
      'Unwilling to live in SRO',
      'Does not want housing at this time',
      'Unsafe environment for this person',
      'Client refused unit (non-SRO)',
      'Client refused voucher',
    ].freeze

    APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_HSA_ONLY_REASONS = [
      'CORI',
      'SORI',
      'Client needs higher level of care',
      'Unable to reach client after multiple attempts',
      'Household did not respond after initial acceptance of match',
      'Ineligible for Housing Program',
      'Client refused offer',
      'Self-resolved',
      'Falsification of documents',
      'Additional screening criteria imposed by third parties',
      'Health and Safety',
    ].freeze

    def run!
      MatchRoutes::Base.ensure_all
      ensure_all_match_decision_steps_exist!
      seed_from_csv!
      seed_approve_match_housing_subsidy_admin_reasons!
    end

    # route/step topology (which steps exist per route) stays permanent Ruby (MatchRoutes::*#match_steps),
    # so the step registry is derived live rather than from a dump.
    private def ensure_all_match_decision_steps_exist!
      MatchRoutes::Base.all_routes.each do |route_class|
        route = route_class.first
        next unless route

        route_class.match_steps.each_key do |decision_type|
          MatchDecisionStep.find_or_create_by!(route: route, decision_type: decision_type)
        end
      end
    end

    private def seed_from_csv!
      reasons_by_name = ::MatchDecisionReasons::Base.all.index_by(&:name)
      routes_by_type = MatchRoutes::Base.all_routes.each_with_object({}) { |route_class, hash| hash[route_class.name] = route_class.first }.compact

      csv_text = File.read(Rails.root.join('db', 'seeds', 'match_decision_reason_assignments.csv'))
      CSV.parse(csv_text, headers: true).each do |row|
        route = routes_by_type[row['route_type']]
        reason = reasons_by_name[row['reason_name']]
        next unless route && reason

        MatchDecisionReasonAssignment.find_or_create_by!(route: route, decision_type: row['decision_type'], match_decision_reason: reason, kind: row['kind']) do |assignment|
          assignment.position = row['position'].to_i
          assignment.requires_explanation = row['requires_explanation'] == 'true'
          assignment.audience = row['audience'].presence
        end
      end
    end

    private def seed_approve_match_housing_subsidy_admin_reasons!
      route = MatchRoutes::Default.first
      decision_type = APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_DECISION_TYPE
      MatchDecisionStep.find_or_create_by!(route: route, decision_type: decision_type)

      position = 0
      APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_SHELTER_AGENCY_ONLY_REASONS.each do |name|
        create_assignment!(route, decision_type, name, 'shelter_agency_contacts', position)
        position += 1
      end
      create_assignment!(route, decision_type, 'Other', nil, position)
      position += 1
      APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_HSA_ONLY_REASONS.each do |name|
        create_assignment!(route, decision_type, name, 'housing_subsidy_admin_contacts', position)
        position += 1
      end
    end

    private def create_assignment!(route, decision_type, reason_name, audience, position)
      reason = ::MatchDecisionReasons::Base.find_by(name: reason_name)
      unless reason
        warn "CasSeeds::MatchDecisionReasonAssignments: skipping #{reason_name.inspect}, no matching MatchDecisionReasons::Base row"
        return
      end

      MatchDecisionReasonAssignment.find_or_create_by!(route: route, decision_type: decision_type, match_decision_reason: reason, kind: MatchDecisionReasonAssignment::KIND_DECLINE) do |assignment|
        assignment.audience = audience
        assignment.position = position
      end
    end
  end
end
