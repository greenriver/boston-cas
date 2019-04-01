class BuildingContactsController < AssociatedContactsController
  private

  def contact_owner_source
    Building
  end

  def contact_join_model_source
    @contact_owner.building_contacts
  end

  def join_model_class
    BuildingContact
  end
end
