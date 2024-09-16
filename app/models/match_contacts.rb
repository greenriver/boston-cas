###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchContacts
  # this class represents the modal for editing all of a match's
  # various contact categories together

  # Lots of duplication because of the different associations managed.
  # maybe add some DSl?
  include ActiveModel::Model
  include UpdateableAttributes
  include RelatedDefaultContacts

  attr_accessor :match,
                :shelter_agency_contact_ids,
                :shelter_agency_join_contacts,
                :client_contact_ids,
                :client_join_contacts,
                :dnd_staff_contact_ids,
                :dnd_staff_join_contacts,
                :housing_subsidy_admin_contact_ids,
                :housing_subsidy_admin_join_contacts,
                :ssp_contact_ids,
                :ssp_join_contacts,
                :hsp_contact_ids,
                :hsp_join_contacts,
                :do_contact_ids,
                :do_join_contacts,
                :client_email

  delegate :to_param, to: :match

  def initialize **attrs
    raise 'must provide match' unless attrs[:match]

    super # ActiveModel attribute initializer
    self.shelter_agency_contacts = match.shelter_agency_contacts
    self.client_contacts = match.client_contacts
    self.dnd_staff_contacts = match.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = match.housing_subsidy_admin_contacts
    self.ssp_contacts = match.ssp_contacts
    self.hsp_contacts = match.hsp_contacts
    self.do_contacts = match.do_contacts
    self.shelter_agency_join_contacts = match.client_opportunity_match_contacts.where(shelter_agency: true).index_by(&:contact_id)
    self.client_join_contacts = match.client_opportunity_match_contacts.where(client: true).index_by(&:contact_id)
    self.dnd_staff_join_contacts = match.client_opportunity_match_contacts.where(dnd_staff: true).index_by(&:contact_id)
    self.housing_subsidy_admin_join_contacts = match.client_opportunity_match_contacts.where(housing_subsidy_admin: true).index_by(&:contact_id)
    self.ssp_join_contacts = match.client_opportunity_match_contacts.where(ssp: true).index_by(&:contact_id)
    self.hsp_join_contacts = match.client_opportunity_match_contacts.where(hsp: true).index_by(&:contact_id)
    self.do_join_contacts = match.client_opportunity_match_contacts.where(do: true).index_by(&:contact_id)
    self.client_email = match.client.email
  end

  def save
    return unless valid?

    successful = false
    Contact.transaction do
      # When a type has contacts set, make sure at least one is the primary contact
      shelter_agency_contact_orders = shelter_agency_contact_ids.map { |id| [id, shelter_agency_join_contacts[id.to_i]&.contact_order] }
      shelter_agency_contact_orders.first[-1] = 1 if shelter_agency_contact_orders.present? && shelter_agency_contact_orders.all? { |c| c.last.nil? }
      client_contact_orders = client_contact_ids.map { |id| [id, client_join_contacts[id.to_i]&.contact_order] }
      client_contact_orders.first[-1] = 1 if client_contact_orders.present? && client_contact_orders.all? { |c| c.last.nil? }
      dnd_staff_contact_orders = dnd_staff_contact_ids.map { |id| [id, dnd_staff_join_contacts[id.to_i]&.contact_order] }
      dnd_staff_contact_orders.first[-1] = 1 if dnd_staff_contact_orders.present? && dnd_staff_contact_orders.all? { |c| c.last.nil? }
      housing_subsidy_admin_contact_orders = housing_subsidy_admin_contact_ids.map { |id| [id, housing_subsidy_admin_join_contacts[id.to_i]&.contact_order] }
      housing_subsidy_admin_contact_orders.first[-1] = 1 if housing_subsidy_admin_contact_orders.present? && housing_subsidy_admin_contact_orders.all? { |c| c.last.nil? }
      ssp_contact_orders = ssp_contact_ids.map { |id| [id, ssp_join_contacts[id.to_i]&.contact_order] }
      ssp_contact_orders.first[-1] = 1 if ssp_contact_orders.present? && ssp_contact_orders.all? { |c| c.last.nil? }
      hsp_contact_orders = hsp_contact_ids.map { |id| [id, hsp_join_contacts[id.to_i]&.contact_order] }
      hsp_contact_orders.first[-1] = 1 if hsp_contact_orders.present? && hsp_contact_orders.all? { |c| c.last.nil? }
      do_contact_orders = do_contact_ids.map { |id| [id, do_join_contacts[id.to_i]&.contact_order] }
      do_contact_orders.first[-1] = 1 if do_contact_orders.present? && do_contact_orders.all? { |c| c.last.nil? }

      ClientOpportunityMatchContact.where(match_id: match.id).delete_all
      shelter_agency_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(shelter_agency: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      client_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(client: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      dnd_staff_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(dnd_staff: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      housing_subsidy_admin_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(housing_subsidy_admin: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      ssp_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(ssp: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      hsp_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(hsp: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end
      do_contact_orders.each do |id, contact_order|
        ClientOpportunityMatchContact.create(do: true, contact_id: id, match_id: match.id, contact_order: contact_order)
      end

      successful = true
    end
    # reloading here to get new contact ids. Directly setting the contact id fields triggers UpdateableAttributes causing a duplicate contact to occur.
    match.reload
    self.shelter_agency_join_contacts = match.client_opportunity_match_contacts.where(shelter_agency: true).index_by(&:contact_id)
    self.client_join_contacts = match.client_opportunity_match_contacts.where(client: true).index_by(&:contact_id)
    self.dnd_staff_join_contacts = match.client_opportunity_match_contacts.where(dnd_staff: true).index_by(&:contact_id)
    self.housing_subsidy_admin_join_contacts = match.client_opportunity_match_contacts.where(housing_subsidy_admin: true).index_by(&:contact_id)
    self.ssp_join_contacts = match.client_opportunity_match_contacts.where(ssp: true).index_by(&:contact_id)
    self.hsp_join_contacts = match.client_opportunity_match_contacts.where(hsp: true).index_by(&:contact_id)
    self.do_join_contacts = match.client_opportunity_match_contacts.where(do: true).index_by(&:contact_id)

    successful
  end

  def available_client_contacts base_scope = Contact.active_contacts
    base_scope.where.not(id: client_contact_ids)
  end

  def client_contacts
    Contact.find client_contact_ids
  end

  def client_contacts= contacts
    self.client_contact_ids = contacts.map(&:id)
  end

  # Only some contact types receive notifications
  def progress_update_contact_ids
    ([shelter_agency_contact_ids] +
        [ssp_contact_ids] +
        [hsp_contact_ids]).flatten.compact.uniq
  end

  def self.input_names
    ClientOpportunityMatchContact.contact_type_columns.keys
  end

  def input_names
    self.class.input_names
  end

  def join_contacts_method_for input_name
    ClientOpportunityMatchContact.join_method_for(input_name)
  end

  def available_contacts_method_for input_name
    @available_contacts_methods ||= {
      shelter_agency_contacts: :available_shelter_agency_contacts,
      client_contacts: :available_client_contacts,
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
      client_contacts: :client_contacts,
      dnd_staff_contacts: :dnd_staff_contacts,
      housing_subsidy_admin_contacts: :housing_subsidy_admin_contacts,
      ssp_contacts: :ssp_contacts,
      hsp_contacts: :hsp_contacts,
      do_contacts: :do_contacts,
    }
    @selected_contacts_methods[input_name] || input_name
  end
end
