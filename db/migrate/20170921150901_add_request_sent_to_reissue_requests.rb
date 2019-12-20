class AddRequestSentToReissueRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :reissue_requests, :request_sent_at, :datetime
  end
end
