module Admin
  class UsersController < ApplicationController
    # This controller is namespaced to prevent
    # route collision with Devise

    before_action :authenticate_user!
    before_action :require_admin_or_dnd_staff!

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
    end

    def edit
      @user = user_scope.find params[:id]
      @user.build_contact unless @user.contact
      @client_contacts = Client.where(id: ClientContact.where(contact_id: @user.contact).select(:client_id))
      @subgrantee_contacts = Subgrantee.where(id: SubgranteeContact.where(contact_id: @user.contact).select(:subgrantee_id))
      @building_contacts = Building.where(id: BuildingContact.where(contact_id: @user.contact).select(:building_id))
      @opportunity_contacts = Opportunity.where(id: OpportunityContact.where(contact_id: @user.contact).select(:opportunity_id))
    end

    def update
      @user = user_scope.find params[:id]
      @user.update_attributes user_params
      if @user.save 
        redirect_to({action: :index}, notice: 'User updated')
      else
        flash[:error] = 'Please review the form problems below'
        render :edit
      end
    end

    def destroy
      @user = user_scope.find params[:id]
      @user.destroy
      redirect_to({action: :index}, notice: 'User deleted')
    end

    private
      def user_scope
        User
      end

      def user_params
        params.require(:user).permit(
          :name,
          :email,
          :admin,
          :dnd_staff,
          :housing_subsidy_admin,
          :receive_initial_notification,
          contact_attributes: [:id, :first_name, :last_name, :phone, :email, :role]
        )
      end
      def sort_column
        user_scope.column_names.include?(params[:sort]) ? params[:sort] : 'name'
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      end
  end

end
