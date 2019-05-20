class ContactsController < ApplicationController
  # Note there is a chance this could turn into an abstract base controller
  # for the things that need to manage their contacts e.g. buildings, clients,
  # etc.
  
  before_action :authenticate_user!
  before_action :require_can_view_contacts!
  before_action :require_can_edit_contacts!, only: [:update, :destroy, :create]
  before_action :set_contact, only: [:edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  
  def index
     # search
    @contacts = if params[:q].present?
      contact_scope.text_search(params[:q])
    else
      contact_scope
    end

    # sort / paginate
    @contacts = @contacts
      .preload(:client_opportunity_match_contacts)
      .order(sort_column => sort_direction)
      .page(params[:page]).per(25)
  end
  
  def new
    @contact = contact_scope.new
  end
  
  def create
    @contact = contact_scope.new contact_params
    if @contact.save
      redirect_to action: :index, notice: 'New contact created'
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @contact.update contact_params
      @contact.user.update(first_name: @contact.first_name, last_name: @contact.last_name) if @contact.user.present?
      flash[:notice] = 'Contact updated'
      redirect_to action: :index
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end
  
  def destroy
    @contact.destroy
    flash[:notice] = 'Contact deleted'
    redirect_to({action: :index})
  end
  
  private
    def contact_source
      Contact
    end

    def contact_scope
      Contact.all
    end
    
    def set_contact
      @contact = contact_scope.find params[:id]
    end
    
    def contact_params
      params.require(:contact).permit(
        :first_name,
        :middle_name,
        :last_name,
        :email,
        :phone,
        :cell_phone,
        :role
      )
    end

    def sort_column
      Contact.column_names.include?(params[:sort]) ? params[:sort] : 'last_name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{@query}%"
    end
  
end
