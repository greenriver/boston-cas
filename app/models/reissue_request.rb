###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ReissueRequest < ApplicationRecord
  belongs_to :notification, class_name: 'Notifications::Base'

  acts_as_paranoid
  has_paper_trail
end
