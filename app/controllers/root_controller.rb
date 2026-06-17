###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class RootController < ApplicationController
  skip_before_action :authenticate_user!
  def index
  end
end
