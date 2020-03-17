###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::PathwaysEligible < Rule
  def variable_requirement?
    true
  end

  def available_routes
    MatchRoutes::Base.available.map{|r| [r.id, r.title]}
  end

  def display_for_variable(value)
    available_routes.to_h.try(:[], value.to_i) || value
  end

  private def route(value)
    MatchRoutes::Base.available.find(value)
  end

  def clients_that_fit(scope, requirement)
    # You must have a assessment collection date
    # You must not have had a decline reason after the collection date
    # You can have an assessment collection date but not a decline reason


    if requirement.positive
      scope.where.not(id: ineligible_ids(requirement))
    else
      scope.where(id: ineligible_ids(requirement))
    end
  end

  # Ineligible clients have an appropriate decline that is newer than any
    # assessment
  private def ineligible_ids(requirement)
    Client.joins(client_opportunity_matches: [{decisions: :decline_reason}]).
      where(md_b_t[:updated_at].gt(c_t[:rrh_assessment_collected_at])).
      merge(
        ClientOpportunityMatch.closed.
        on_route(route(requirement.variable))
      ).
      merge(MatchDecisionReasons::Base.ineligible_in_warehouse).
      select(:id)
  end
end
