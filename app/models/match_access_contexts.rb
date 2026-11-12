###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchAccessContexts
  # Every match route requires a signed-in user, whose contact is the acting contact.
  # Routes under a notification link do too; the notification code grants no access.
  def self.build controller
    AuthenticatedUser.new(controller)
  end
end
