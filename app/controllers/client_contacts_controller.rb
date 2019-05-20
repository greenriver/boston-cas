class ClientContactsController < AssociatedContactsController

  private

    def contact_owner_source
      Client
    end
    
    def contact_join_model_source
      @contact_owner.client_contacts
    end
    
    def join_model_class
      ClientContact
    end

end