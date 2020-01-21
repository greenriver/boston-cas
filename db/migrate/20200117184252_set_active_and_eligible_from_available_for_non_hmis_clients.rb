class SetActiveAndEligibleFromAvailableForNonHmisClients < ActiveRecord::Migration
  def up
    NonHmisClient.update_all('active_client=available')
    NonHmisClient.update_all('eligible_for_matching=available')
  end
end
