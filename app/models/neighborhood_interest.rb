class NeighborhoodInterest < ActiveRecord::Base
  belongs_to :client
  belongs_to :neighborhood

  scope :for_client, -> (client) do
    where(client_id: client.id)
  end
end