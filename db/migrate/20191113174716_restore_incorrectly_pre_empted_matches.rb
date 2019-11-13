class RestoreIncorrectlyPreEmptedMatches < ActiveRecord::Migration
  def change
    available_decisions = MatchRoutes::Base.all_routes.flat_map{|r| r.match_steps_for_reporting.keys }
    ClientOpportunityMatch.successful.find_each do |match|
      o = match.opportunity
      puts "Restoring #{o.closed_matches.only_deleted.count} matches related to match id: #{match.id}"
      o.closed_matches.only_deleted.each do |m|
        m.restore
        m.contacts.only_deleted.each(&:restore)
        m.events.only_deleted.each(&:restore)
        m.decisions.only_deleted.where(type: available_decisions).each(&:restore)
        m.update(match_route_id: m.program.match_route_id) if m.match_route_id.blank?
      end
    end
  end
end
