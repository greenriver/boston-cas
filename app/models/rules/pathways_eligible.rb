###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::PathwaysEligible < Rule
  def clients_that_fit(scope, requirement, opportunity)
    return scope unless opportunity

    # You must have a assessment collection date
    # You must not have had a decline reason after the collection date
    # You can have an assessment collection date but not a decline reason
    if requirement.positive
      scope.where.not(id: ineligible_ids(opportunity))
    else
      scope.where(id: ineligible_ids(opportunity))
    end
  end

  # Ineligible clients have an appropriate decline that is newer than any
    # assessment
  private def ineligible_ids(opportunity)
    Client.joins(client_opportunity_matches: [{decisions: :decline_reason}]).
      where(md_b_t[:updated_at].gt(c_t[:rrh_assessment_collected_at])).
      merge(
        ClientOpportunityMatch.closed.
        on_route(opportunity.match_route)
      ).
      merge(MatchDecisionReasons::Base.ineligible_in_warehouse).
      select(:id)
  end
end
