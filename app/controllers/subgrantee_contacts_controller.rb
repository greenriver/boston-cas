###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class SubgranteeContactsController < AssociatedContactsController

  private

    def contact_owner_source
      Subgrantee
    end

    def contact_join_model_source
      @contact_owner.subgrantee_contacts
    end

    def join_model_class
      SubgranteeContact
    end

end
