module Admin
  class UsersController < ApplicationController
    # This controller is namespaced to prevent
    # route collision with Devise

    before_action :authenticate_user!
    before_action :require_can_edit_users!
    before_action :set_user, only: [:edit, :update, :destroy]
    before_action :set_editable_programs, only: [:edit, :update]

    helper_method :sort_column, :sort_direction

    def index
      # search
      @users = if params[:q].present?
        user_scope.text_search(params[:q])
      else
        user_scope
      end

      # sort / paginate
      @users = @users
        .order(sort_column => sort_direction)
        .page(params[:page]).per(25)
      if current_user.can_become_other_users?
        @available_for_becoming = User.non_admin.pluck(:id)
      end
      @inactive_users = User.inactive
    end

    def edit
      # check for existing contact with the same email
      contact = Contact.where("LOWER(email) = ?", @user.email.downcase)&.first
      if ! @user.contact
        if contact.present?
          @user.contact = contact
        else
          @user.build_contact
        end
      end
      @client_contacts = Client.where(id: ClientContact.where(contact_id: @user.contact).select(:client_id))
      @subgrantee_contacts = Subgrantee.where(id: SubgranteeContact.where(contact_id: @user.contact).select(:subgrantee_id))
      @building_contacts = Building.where(id: BuildingContact.where(contact_id: @user.contact).select(:building_id))
      @opportunity_contacts = Opportunity.where(id: OpportunityContact.where(contact_id: @user.contact).select(:opportunity_id))
    end

    def update
      requested_programs = programs_params[:editable_programs].reject(&:blank?).map(&:to_i)
      update_editable_programs(requested_programs)

      @user.update_attributes user_params
      if @user.save
        redirect_to({action: :index}, notice: 'User updated')
      else
        flash[:error] = 'Please review the form problems below'
        render :edit
      end
    end

    def destroy
      @user.update(active: false)
      redirect_to({action: :index}, notice: 'User deactivated')
    end

    private
      def update_editable_programs(requested_programs)
        removed_programs = @editable_programs - requested_programs
        removed_programs.each do |program_id|
          EntityViewPermission.where(entity: Program.find(program_id), user: @user).destroy_all
        end

        added_programs = requested_programs - @editable_programs
        added_programs.each do |program_id|
          EntityViewPermission.create(entity: Program.find(program_id), user: @user, editable: true)
        end
      end
      def set_user
        @user = user_scope.find params[:id]
      end

      def user_scope
        User.active
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :email,
          :receive_initial_notification,
          :agency,
          role_ids: [],
          contact_attributes: [:id, :first_name, :last_name, :phone, :email, :role]
        )
      end

      def programs_params
        params.require(:user).permit(
          editable_programs: [],
        )
      end

      def set_editable_programs
        @editable_programs = Program.editable_by(@user).pluck(:entity_id)
      end

      def sort_column
        user_scope.column_names.include?(params[:sort]) ? params[:sort] : 'last_name'
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      end
  end

end
