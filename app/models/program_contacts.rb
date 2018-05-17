class ProgramContacts
  # this class represents the modal for editing all of a program's
  # various contact categories together
  
  # Lots of duplication because of the different associations managed.
  # maybe add some DSl?
  include ActiveModel::Model
  include UpdateableAttributes
  
  attr_accessor :program,
    :shelter_agency_contact_ids,
    :client_contact_ids,
    :dnd_staff_contact_ids,
    :housing_subsidy_admin_contact_ids,
    :ssp_contact_ids,
    :hsp_contact_ids
  
  delegate :to_param, to: :program

  def initialize **attrs
    raise "must provide program" unless attrs[:program]
    super #ActiveModel attribute initializer
    self.shelter_agency_contacts = program.shelter_agency_contacts
    self.client_contacts = program.client_contacts
    self.dnd_staff_contacts = program.dnd_contacts
    self.housing_subsidy_admin_contacts = program.housing_subsidy_admin_contacts
    self.ssp_contacts = program.ssp_contacts
    self.hsp_contacts = program.hsp_contacts
  end
  
  def save
    if valid?
      program.shelter_agency_contact_ids = shelter_agency_contact_ids
      program.client_contact_ids = client_contact_ids
      program.dnd_contact_ids = dnd_staff_contact_ids
      program.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids
      program.ssp_contact_ids = ssp_contact_ids
      program.hsp_contact_ids = hsp_contact_ids
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

  def available_ssp_contacts base_scope = Contact.all
    base_scope.where.not(id: ssp_contact_ids)
  end

  def available_hsp_contacts base_scope = Contact.all
    base_scope.where.not(id: hsp_contact_ids)
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

  def ssp_contacts
    Contact.find ssp_contact_ids
  end

  def hsp_contacts
    Contact.find hsp_contact_ids
  end
  
  def ssp_contacts= contacts
    self.ssp_contact_ids = contacts.map(&:id)
  end

  def hsp_contacts= contacts
    self.hsp_contact_ids = contacts.map(&:id)
  end

end