class SetParkedClientDetails < ActiveRecord::Migration[7.0]
  def up
    # Set user, match, and reason for parked clients where possible
    unavailable_client_ids = UnavailableAsCandidateFor.distinct.pluck(:client_id)

    # Successful matches
    MatchRoutes::Base.active.each do |route|
      matches = ClientOpportunityMatch.successful.on_route(route).where(client_id: unavailable_client_ids)
      client_ids = matches.map(&:client_id)
      # not preloading versions since we only want the first version anyway, which would result in a bigger query
      parked = UnavailableAsCandidateFor.for_route(route).where(client_id: client_ids).group_by(&:client_id)
      matches.each do |match|
        parked_for_client = parked[match.client_id]
        next unless parked_for_client

        parked_for_client.each do |record|
          # NOTE: individual saves, probably fine, but means the migration might be slow
          record.update(reason: 'Successful Match', user_id: record.versions&.first&.user_id)
        end
      end
    end

    # Ongoing matches
    MatchRoutes::Base.active.each do |route|
      matches = ClientOpportunityMatch.active.on_route(route).where(client_id: unavailable_client_ids).group_by(&:client_id)
      UnavailableAsCandidateFor.for_route(route).where(client_id: matches.keys).find_each do |record|
        record.update(reason: 'Active Match', user_id: record.versions&.first&.user_id, match_id: matches[record.client_id].first.id)
      end
    end

    # Parked (everyone else)
    UnavailableAsCandidateFor.where(reason: nil).find_each do |record|
      record.update(reason: 'Parked', user_id: record.versions&.first&.user_id)
    end
  end
end
