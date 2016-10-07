module Admin
  class RecreateInvitationsController < ::ApplicationController
    before_action :require_admin!

    def create
      @user = User.find params[:user_id]
      @user.invite!
      flash[:notice] = "Account activation instructions resent to #{@user.email}"
      redirect_to admin_users_path
    end

  end
end
