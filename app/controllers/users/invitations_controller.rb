###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Users::InvitationsController < Devise::InvitationsController

  prepend_before_action :require_can_edit_users!, only: [:new, :create]

  # GET /resource/invitation/new
  def new
    @user = User.new
    @user.build_contact
  end

  def confirm
    @user = User.new
    @user.build_contact
    if ! creating_admin?
      create
    end
  end

  # POST /resource/invitation
  def create
    if creating_admin?
      if ! current_user.valid_password?(confirmation_params[:confirmation_password])
        flash[:error] = "User not updated. Incorrect password"
        @user = User.new
        @user.build_contact
        render :confirm
        return
      end
    end
    user_attrs = invite_params[:contact_attributes].except(:phone)
    user_attrs[:role_ids] = invite_params[:role_ids]
    user_attrs[:email] = user_attrs[:email].downcase
    user_attrs[:agency_id] = invite_params[:agency_id]
    @user = User.invite!(user_attrs, current_user)

    requested_programs = programs_params[:editable_programs].reject(&:blank?).map(&:to_i)
    requested_programs.each do |program_id|
      EntityViewPermission.create(entity: Program.find(program_id), user: @user, editable: true)
    end

    c_t = Contact.arel_table
    contact = Contact.where(email: user_attrs[:email].downcase).first_or_create
    contact.update(first_name: @user.first_name, last_name: @user.last_name)
    @user.update(contact: contact)
    if resource.errors.empty?
      if is_flashing_format? && self.resource.invitation_sent_at

        set_flash_message :notice, :send_instructions, :email => user_attrs['email']
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
      :first_name,
      :last_name,
      :email,
      :agency_id,
      role_ids: [],
      contact_attributes: [:first_name, :last_name, :phone, :email]
    )
  end

  private def programs_params
    params.require(:user).permit(
        editable_programs: [],
    )
  end

  private def confirmation_params
    params.require(:user).permit(
      :confirmation_password
    )
  end

  private def creating_admin?
    role_ids = invite_params[:role_ids]&.select{|v| v.present?}&.map(&:to_i) || []
    role_ids.each do |id|
      role = Role.find(id)
      if role.administrative?
        @admin_role_name = role.name.humanize
        return true
      end
    end
    return false
  end

end

