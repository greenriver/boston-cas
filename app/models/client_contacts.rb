class ClientContacts
  # this class represents the modal for editing all of a client's
  # various contact categories together

  # Lots of duplication because of the different associations managed.

  include ActiveModel::Model
  include UpdateableAttributes

  attr_accessor :client,
                :shelter_agency_contact_ids,
                :regular_contact_ids,
                :dnd_staff_contact_ids,
                :housing_subsidy_admin_contact_ids,
                :ssp_contact_ids,
                :hsp_contact_ids,
                :do_contact_ids

  delegate :to_param, to: :client

  def initialize **attrs
    raise "must provide cliewt" unless attrs[:client]
    super #ActiveModel attribute initializer
    self.shelter_agency_contacts = client.shelter_agency_contacts
    self.regular_contacts = client.regular_contacts
    self.dnd_staff_contacts = client.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = client.housing_subsidy_admin_contacts
    self.ssp_contacts = client.ssp_contacts
    self.hsp_contacts = client.hsp_contacts
    self.do_contacts = client.do_contacts
  end

  def save
    if valid?
      Contact.transaction do
        ClientContact.where(client_id: client.id).delete_all

        shelter_agency_contact_ids.each do |id|
          ClientContact.create(shelter_agency: true, contact_id: id, client_id: client.id)
        end
        regular_contact_ids.each do |id|
          ClientContact.create(regular: true, contact_id: id, client_id: client.id)
        end
        dnd_staff_contact_ids.each do |id|
          ClientContact.create(dnd_staff: true, contact_id: id, client_id: client.id)
        end
        housing_subsidy_admin_contact_ids.each do |id|
          ClientContact.create(housing_subsidy_admin: true, contact_id: id, client_id: client.id)
        end
        ssp_contact_ids.each do |id|
          ClientContact.create(ssp: true, contact_id: id, client_id: client.id)
        end
        hsp_contact_ids.each do |id|
          ClientContact.create(hsp: true, contact_id: id, client_id: client.id)
        end
        do_contact_ids.each do |id|
          ClientContact.create(do: true, contact_id: id, client_id: client.id)
        end

        return true
      end

      client.shelter_agency_contact_ids = shelter_agency_contact_ids.map(&:to_i)
      client.regular_contact_ids = regular_contact_ids.map(&:to_i)
      client.dnd_staff_contact_ids = dnd_staff_contact_ids.map(&:to_i)
      client.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids.map(&:to_i).uniq
      client.ssp_contact_ids = ssp_contact_ids.map(&:to_i)
      client.hsp_contact_ids = hsp_contact_ids.map(&:to_i)
      client.do_contact_ids = do_contact_ids.map(&:to_i)
    end
  end

  def available_shelter_agency_contacts base_scope = Contact.all
    base_scope.where.not(id: shelter_agency_contact_ids)
  end

  def available_regular_contacts base_scope = Contact.all
    base_scope.where.not(id: regular_contact_ids)
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

  def available_do_contacts base_scope = Contact.all
    base_scope.where.not(id: do_contact_ids)
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

  def regular_contacts
    Contact.find regular_contact_ids
  end

  def regular_contacts= contacts
    self.regular_contact_ids = contacts.map(&:id)
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

  def do_contacts
    Contact.find do_contact_ids
  end

  def ssp_contacts= contacts
    self.ssp_contact_ids = contacts.map(&:id)
  end

  def hsp_contacts= contacts
    self.hsp_contact_ids = contacts.map(&:id)
  end

  def do_contacts= contacts
    self.do_contact_ids = contacts.map(&:id)
  end

  # Only some contact types receive notifications
  def progress_update_contact_ids
    ([shelter_agency_contact_ids] +
        [ssp_contact_ids] +
        [hsp_contact_ids]).flatten.compact.uniq
  end

  def self.input_names
    [
        :regular_contacts,
        :shelter_agency_contacts,
        :dnd_staff_contacts,
        :housing_subsidy_admin_contacts,
        :ssp_contacts,
        :hsp_contacts,
        :do_contacts,
    ]
  end

  def input_names
    self.class.input_names
  end

  def label_for(input_name)
    @labels ||= {
        shelter_agency_contacts: "#{_('Shelter Agency')} and/or #{_('Housing Search Worker')} Contacts",
        regular_contacts: "Client Contacts",
        dnd_staff_contacts: "#{_('DND')} Staff Contacts",
        housing_subsidy_admin_contacts: "#{_('Housing Subsidy Administrator')} Contacts",
        ssp_contacts: "#{_('Stabilization Service Provider')}",
        hsp_contacts: "#{_('Housing Search Provider')}",
        do_contacts: "#{_('Development Officer Contacts')}",
    }
    @labels[input_name] || input_name
  end

  def contact_type_for(input_name)
    @contact_types ||= {
        shelter_agency_contacts: 'shelter_agency',
        regular_contacts: "regular",
        dnd_staff_contacts: "dnd_staff",
        housing_subsidy_admin_contacts: "housing_subsidy_admin",
        ssp_contacts: "ssp",
        hsp_contacts: "hsp",
        do_contacts: "do",
    }
    @contact_types[input_name] || input_name
  end

  def available_contacts_method_for input_name
    @available_contacts_methods ||= {
        shelter_agency_contacts: :available_shelter_agency_contacts,
        regular_contacts: :available_regular_contacts,
        dnd_staff_contacts: :available_dnd_staff_contacts,
        housing_subsidy_admin_contacts: :available_housing_subsidy_admin_contacts,
        ssp_contacts: :available_ssp_contacts,
        hsp_contacts: :available_hsp_contacts,
        do_contacts: :available_do_contacts,
    }
    @available_contacts_methods[input_name] || input_name
  end

  def selected_contacts_method_for input_name
    @selected_contacts_methods ||= {
        shelter_agency_contacts: :shelter_agency_contacts,
        regular_contacts: :regular_contacts,
        dnd_staff_contacts: :dnd_staff_contacts,
        housing_subsidy_admin_contacts: :housing_subsidy_admin_contacts,
        ssp_contacts: :ssp_contacts,
        hsp_contacts: :hsp_contacts,
        do_contacts: :do_contacts,
    }
    @selected_contacts_methods[input_name] || input_name
  end
end
