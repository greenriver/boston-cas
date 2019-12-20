###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ClientNote < ApplicationRecord
  belongs_to :client
  belongs_to :user
  validates :note, presence: true

  acts_as_paranoid
  has_paper_trail
  
  def user_can_destroy?(user)
    user.id == self.user_id || user.can_delete_client_notes?
  end
end
