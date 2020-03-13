class UpdateExistingUnavailableFors < ActiveRecord::Migration[6.0]
  def up
    expiration_length = Config.get(:unavailable_for_length)
    return if expiration_length.zero?

    UnavailableAsCandidateFor.find_each do |u|
      u.update(expires_at: u.created_at + expiration_length.days)
    end

    Client.where("prevent_matching_until >= ?", Date.current).find_each do |client|
      client.make_unavailable_in_all_routes(expires_at: client.prevent_matching_until)
    end
  end
end
