###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Admin::BecomesController < ::ApplicationController
  before_action :require_can_become_other_users! 

  def show
    user = prevent_becoming_admin_or_developer()
    if user.present?
      sign_in(:user, user, { bypass: true })
      flash[:success] = "You are now logged in as #{user.name}.  Remember to logout after you complete your troubleshooting."
    else
      flash[:error] = 'Becoming Admins and Developers is not allowed'
    end
    redirect_to root_url
  end

  def prevent_becoming_admin_or_developer
    User.non_admin.
      where(id: params[:user_id].to_i).first
  end
end