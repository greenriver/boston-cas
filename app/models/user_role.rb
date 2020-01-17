###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class UserRole < ActiveRecord::Base

  belongs_to :user, inverse_of: :user_roles
  belongs_to :role, inverse_of: :user_roles

  delegate :administrative?, to: :role

end
