###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ReissueNotification < ApplicationRecord
  self.table_name = 'reissue_requests'
  belongs_to :notification, class_name: 'Notifications::Base'

  acts_as_paranoid
  has_paper_trail
end
