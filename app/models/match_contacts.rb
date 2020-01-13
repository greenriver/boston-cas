###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
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
    :client_contact_ids,
    :dnd_staff_contact_ids,
    :housing_subsidy_admin_contact_ids,
    :ssp_contact_ids,
    :hsp_contact_ids,
    :do_contact_ids

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
    self.do_contacts = match.do_contacts
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
        do_contact_ids.each do |id|
          ClientOpportunityMatchContact.create(do: true, contact_id: id, match_id: match.id)
        end

        return true
      end

      match.shelter_agency_contact_ids = shelter_agency_contact_ids.map(&:to_i)
      match.client_contact_ids = client_contact_ids.map(&:to_i)
      match.dnd_staff_contact_ids = dnd_staff_contact_ids.map(&:to_i)
      match.housing_subsidy_admin_contact_ids = housing_subsidy_admin_contact_ids.map(&:to_i).uniq
      match.ssp_contact_ids = ssp_contact_ids.map(&:to_i)
      match.hsp_contact_ids = hsp_contact_ids.map(&:to_i)
      match.do_contact_ids = do_contact_ids.map(&:to_i)
    end
  end

  def available_client_contacts base_scope = Contact.all
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
    [
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
