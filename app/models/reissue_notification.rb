###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ReissueNotification < ActiveRecord::Base
  self.table_name = 'reissue_requests'
  belongs_to :notification, class_name: 'Notifications::Base'

  acts_as_paranoid
  has_paper_trail
end
