class Users::InvitationsController < Devise::InvitationsController

  prepend_before_action :require_admin!, only: [:new, :create]

  # GET /resource/invitation/new
  def new
    @user = User.new
    @user.build_contact
  end

  # POST /resource/invitation
  def create
    @user = User.invite!(invite_params, current_user)

    if resource.errors.empty?
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      redirect_to admin_users_path
    else
      render :new
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    super
  end

  # PUT /resource/invitation
  def update
    super
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    super
  end

  protected

  private def invite_params
    params.require(:user).permit(
      :name,
      :email,
      :admin,
      :dnd_staff,
      :housing_subsidy_admin,
      contact_attributes: [:first_name, :last_name, :phone, :email]
      )
  end

end

