###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientContacts
  # this class represents the modal for editing all of a client's
  # various contact categories together

  # Lots of duplication because of the different associations managed.

  include ActiveModel::Model
  include UpdateableAttributes
  include RelatedDefaultContacts

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
    raise 'must provide client' unless attrs[:client]

    super # ActiveModel attribute initializer
    self.shelter_agency_contacts = client.shelter_agency_contacts
    self.regular_contacts = client.regular_contacts
    self.dnd_staff_contacts = client.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = client.housing_subsidy_admin_contacts
    self.ssp_contacts = client.ssp_contacts
    self.hsp_contacts = client.hsp_contacts
    self.do_contacts = client.do_contacts
  end

  def save
    return unless valid?

    successful = false
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

      successful = true
    end

    client.shelter_agency_contact_ids = shelter_agency_contact_ids.map(&:to_i)
    client.regular_contact_ids = regular_contact_ids.map(&:to_i)
    client.dnd_staff_contact_ids = dnd_staff_contact_ids.map(&:to_i)
    client.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids.map(&:to_i).uniq
    client.ssp_contact_ids = ssp_contact_ids.map(&:to_i)
    client.hsp_contact_ids = hsp_contact_ids.map(&:to_i)
    client.do_contact_ids = do_contact_ids.map(&:to_i)

    successful
  end

  def available_regular_contacts base_scope = Contact.active_contacts
    base_scope.where.not(id: regular_contact_ids)
  end

  def regular_contacts
    Contact.find regular_contact_ids
  end

  def regular_contacts= contacts
    self.regular_contact_ids = contacts.map(&:id)
  end

  # Only some contact types receive notifications
  def progress_update_contact_ids
    ([shelter_agency_contact_ids] +
        [ssp_contact_ids] +
        [hsp_contact_ids]).flatten.compact.uniq
  end

  def self.input_names
    ClientContact.contact_type_columns.keys
  end

  def input_names
    self.class.input_names
  end

  def available_contacts_method_for input_name
    ClientContact.available_contact_method_for(input_name)
  end

  def selected_contacts_method_for input_name
    ClientContact.selected_contact_method_for(input_name)
  end
end
