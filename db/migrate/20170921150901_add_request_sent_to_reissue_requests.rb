class AddRequestSentToReissueRequests < ActiveRecord::Migration
  def change
    add_column :reissue_requests, :request_sent_at, :datetime
  end
end
