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

    # Ineligible clients have an appropriate decline that is newer than any
    # assessment
    ineligible_ids = ClientOpportunityMatch.closed.
      on_route(route(requirement.variable)).
      joins(:client, decisions: :decline_reason).
      merge(MatchDecisionReasons::Base.ineligible_in_warehouse).
      merge(Client.where(md_t[:updated_at].gt(c_t[:rrh_assessment_collected_at]))).
      select(:client_id)

    # client_ids = Client.where.not(rrh_assessment_collected_at: nil).
    #   left_outer_joins(client_opportunity_matches: [{decisions: :decline_reason}]).
    #   merge(ClientOpportunityMatch.where(closed: [true, nil])).
    #   merge(MatchDecisionReasons::Base.where(ineligible_in_warehouse: [true, nil])).
    #   where(
    #     md_t[:updated_at].lt(c_t[:rrh_assessment_collected_at]).
    #     and(mdr_t[:ineligible_in_warehouse])
    #   ).select(:id)

    if requirement.positive
      scope.where.not(id: ineligible_ids)
    else
      scope.where(id: ineligible_ids)
    end
  end
end
