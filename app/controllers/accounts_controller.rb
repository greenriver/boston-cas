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
    # for tests
    send_match_summary_email_on = Config.get(:send_match_summary_email_on) if Rails.env.test? # rubocop:disable Lint/UselessAssignment
    config = Config.last
    changed_notes = []
    changed_notes << 'Account name was updated.' if @user.first_name != account_params[:first_name] || @user.last_name != account_params[:last_name]

    changed_notes << 'Email schedule was updated.' if @user.email_schedule != account_params[:email_schedule]

    params_opt_out = account_params[:receive_weekly_match_summary_email].to_s == '1'
    if @user.receive_weekly_match_summary_email != params_opt_out && ! config.never_send_match_summary_email?
      changed_notes << if params_opt_out
        'You have opted out of weekly match digest emails'
      else
        "You will receive weekly match digest emails on #{config.send_match_summary_email_on_day}"
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
        :receive_weekly_match_summary_email,
      )
  end

  private def set_user
    @user = current_user
  end
end
