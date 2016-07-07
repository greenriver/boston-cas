class ReissueNotification < ActiveRecord::Base
  self.table_name = 'reissue_requests'
  belongs_to :notification, class_name: 'Notifications::Base'

  acts_as_paranoid
  has_paper_trail
end
