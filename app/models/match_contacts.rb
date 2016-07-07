class MatchContacts
  # this class represents the modal for editing all of a match's
  # various contact categories together
  
  # Lots of duplication because of the different associations managed.
  # maybe add some DSl?
  include ActiveModel::Model
  include UpdateableAttributes
  
  attr_accessor :match,
    :shelter_agency_contact_ids,
    :client_contact_ids,
    :dnd_staff_contact_ids,
    :housing_subsidy_admin_contact_ids
  
  delegate :to_param, to: :match

  def initialize **attrs
    raise "must provide match" unless attrs[:match]
    super #ActiveModel attribute initializer
    self.shelter_agency_contacts = match.shelter_agency_contacts
    self.client_contacts = match.client_contacts
    self.dnd_staff_contacts = match.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = match.housing_subsidy_admin_contacts
  end
  
  def save
    if valid?
      match.shelter_agency_contact_ids = shelter_agency_contact_ids
      match.client_contact_ids = client_contact_ids
      match.dnd_staff_contact_ids = dnd_staff_contact_ids
      match.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids
    end
  end
  
  def available_shelter_agency_contacts base_scope = Contact.all
    base_scope.where.not(id: shelter_agency_contact_ids)
  end
  
  def available_client_contacts base_scope = Contact.all
    base_scope.where.not(id: client_contact_ids)
  end
  
  def available_dnd_staff_contacts base_scope = Contact.all
    base_scope
      .where(user_id: User.dnd_staff)
      .where.not(id: dnd_staff_contact_ids)
  end

  def available_housing_subsidy_admin_contacts base_scope = Contact.all
    base_scope
      .where(user_id: User.housing_subsidy_admin)
      .where.not(id: housing_subsidy_admin_contact_ids)
  end

  def persisted?
    true
  end
  
  def shelter_agency_contacts
    Contact.find shelter_agency_contact_ids
  end
  
  def shelter_agency_contacts= contacts
    self.shelter_agency_contact_ids = contacts.map(&:id)
  end
  
  def client_contacts
    Contact.find client_contact_ids
  end
  
  def client_contacts= contacts
    self.client_contact_ids = contacts.map(&:id)
  end
  
  def dnd_staff_contacts
    Contact.find dnd_staff_contact_ids
  end
  
  def dnd_staff_contacts= contacts
    self.dnd_staff_contact_ids = contacts.map(&:id)
  end
  
  def housing_subsidy_admin_contacts
    Contact.find housing_subsidy_admin_contact_ids
  end
  
  def housing_subsidy_admin_contacts= contacts
    self.housing_subsidy_admin_contact_ids = contacts.map(&:id)
  end

end