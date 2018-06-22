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
    :housing_subsidy_admin_contact_ids,
    :ssp_contact_ids,
    :hsp_contact_ids
  
  delegate :to_param, to: :match

  def initialize **attrs
    raise "must provide match" unless attrs[:match]
    super #ActiveModel attribute initializer
    self.shelter_agency_contacts = match.shelter_agency_contacts
    self.client_contacts = match.client_contacts
    self.dnd_staff_contacts = match.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = match.housing_subsidy_admin_contacts
    self.ssp_contacts = match.ssp_contacts
    self.hsp_contacts = match.hsp_contacts
  end
  
  def save
    if valid?
      Contact.transaction do
        ClientOpportunityMatchContact.where(match_id: match.id).delete_all
        
        shelter_agency_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(shelter_agency: true, contact_id: id, match_id: match.id)
        end
        client_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(client: true, contact_id: id, match_id: match.id)
        end
        dnd_staff_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(dnd_staff: true, contact_id: id, match_id: match.id)
        end
        housing_subsidy_admin_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(housing_subsidy_admin: true, contact_id: id, match_id: match.id)
        end
        ssp_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(ssp: true, contact_id: id, match_id: match.id)
        end
        hsp_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(hsp: true, contact_id: id, match_id: match.id)
        end

        return true
      end

      match.shelter_agency_contact_ids = shelter_agency_contact_ids.map(&:to_i)
      match.client_contact_ids = client_contact_ids.map(&:to_i)
      match.dnd_staff_contact_ids = dnd_staff_contact_ids.map(&:to_i)
      match.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids.map(&:to_i).uniq
      match.ssp_contact_ids = ssp_contact_ids.map(&:to_i)
      match.hsp_contact_ids = hsp_contact_ids.map(&:to_i)
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

  # Only some contact types receive notifications
  def progress_update_contact_ids
    ([shelter_agency_contact_ids] +
        [ssp_contact_ids] +
        [hsp_contact_ids]).flatten.compact.uniq
  end
  
  def label_for(input_name)
    @labels ||= {
      shelter_agency_contacts: "#{_('Shelter Agency')} and/or #{_('Housing Search Worker')} Contacts",
      client_contacts: "Client Contacts",
      dnd_staff_contacts: "#{_('DND')} Staff Contacts", 
      housing_subsidy_admin_contacts: "#{_('Housing Subsidy Administrator')} Contacts", 
      ssp_contacts: "#{_('Stabilization Service Provider')}", 
      hsp_contacts: "#{_('Housing Search Provider')}",
    }
    @labels[input_name] || input_name
  end
  
  def contact_type_for(input_name)
    @contact_types ||= {
      shelter_agency_contacts: 'shelter_agency',
      client_contacts: "client",
      dnd_staff_contacts: "dnd_staff", 
      housing_subsidy_admin_contacts: "housing_subsidy_admin", 
      ssp_contacts: "ssp", 
      hsp_contacts: "hsp",
    }
    @contact_types[input_name] || input_name
  end
  
  def available_contacts_method_for input_name
    @available_contacts_methods ||= {
      shelter_agency_contacts: :available_shelter_agency_contacts,
      client_contacts: :available_client_contacts,
      dnd_staff_contacts: :available_dnd_staff_contacts, 
      housing_subsidy_admin_contacts: :available_housing_subsidy_admin_contacts, 
      ssp_contacts: :available_ssp_contacts, 
      hsp_contacts: :available_hsp_contacts,
    }
    @available_contacts_methods[input_name] || input_name
  end
  
  def selected_contacts_method_for input_name
    @selected_contacts_methods ||= {
      shelter_agency_contacts: :shelter_agency_contacts,
      client_contacts: :client_contacts,
      dnd_staff_contacts: :dnd_staff_contacts, 
      housing_subsidy_admin_contacts: :housing_subsidy_admin_contacts, 
      ssp_contacts: :ssp_contacts, 
      hsp_contacts: :hsp_contacts,
    }
    @selected_contacts_methods[input_name] || input_name
  end
end
