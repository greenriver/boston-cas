###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit
  end

  def update
    changed_notes = []
    changed_notes << 'Account name was updated.' if @user.first_name != account_params[:first_name] || @user.last_name != account_params[:last_name]

    changed_notes << 'Email schedule was updated.' if @user.email_schedule != account_params[:email_schedule]

    params_opt_out = account_params[:opt_out_match_digest_email] == '1'
    if @user.opt_out_match_digest_email != params_opt_out
      config = Config.last
      if params_opt_out
        changed_notes << 'You have opted out of weekly match digest emails'
      else
        changed_notes << "You will receive weekly match digest emails on #{config.send_match_summary_email_on_day}"
      end
    end

    if changed_notes.present?
      flash[:notice] = changed_notes.join(' ')
      @user.update(account_params)
      bypass_sign_in(@user)
    end
    redirect_to edit_account_path
  end

  def locations
    @locations = @user.login_activities.order(created_at: :desc).
      page(params[:page]).per(50)
  end

  private def account_params
    params.require(:user).
      permit(
        :first_name,
        :last_name,
        :email_schedule,
        :opt_out_match_digest_email,
      )
  end

  private def set_user
    @user = current_user
  end
end
