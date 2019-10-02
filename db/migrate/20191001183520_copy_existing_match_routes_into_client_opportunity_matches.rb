class CopyExistingMatchRoutesIntoClientOpportunityMatches < ActiveRecord::Migration
  def change
    ClientOpportunityMatch.find_each do |match|
      match.update!(match_route_id: match.program.match_route.id)
    end
  end
end
