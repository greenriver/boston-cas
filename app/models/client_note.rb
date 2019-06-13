###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ClientNote < ActiveRecord::Base
  belongs_to :client, required: true
  belongs_to :user, required: true
  validates :note, presence: true

  acts_as_paranoid
  has_paper_trail
  
  def user_can_destroy?(user)
    user.id == self.user_id || user.can_delete_client_notes?
  end
end
