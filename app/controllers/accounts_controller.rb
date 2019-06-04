###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit

  end

  def update
    changed_notes = []
    if @user.first_name != account_params[:first_name] || @user.last_name != account_params[:last_name]
      changed_notes << "Account name was updated."
    end
    if @user.email_schedule != account_params[:email_schedule]
      changed_notes << "Email schedule was updated."
    end

    if changed_notes.present?
      flash[:notice] = changed_notes.join(' ')
      @user.update(account_params)
      bypass_sign_in(@user)
    end
    redirect_to edit_account_path
  end

  private def account_params
    params.require(:user).
      permit(
        :first_name,
        :last_name,
        :email_schedule,
      )
  end

  private def set_user
    @user = current_user
  end

end