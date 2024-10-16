###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# FIXME Remove, dead code
class ProgramContacts
  # this class represents the modal for editing all of a program's
  # various contact categories together

  # Lots of duplication because of the different associations managed.
  # maybe add some DSl?
  include ActiveModel::Model
  include UpdateableAttributes
  include RelatedDefaultContacts

  attr_accessor :program,
                :shelter_agency_contact_ids,
                :client_contact_ids,
                :dnd_staff_contact_ids,
                :housing_subsidy_admin_contact_ids,
                :ssp_contact_ids,
                :hsp_contact_ids,
                :do_contact_ids

  delegate :to_param, to: :program

  def initialize(**attrs)
    raise 'must provide program' unless attrs[:program]

    super # ActiveModel attribute initializer
    self.shelter_agency_contacts = program.shelter_agency_contacts
    self.client_contacts = program.client_contacts
    self.dnd_staff_contacts = program.dnd_staff_contacts
    self.housing_subsidy_admin_contacts = program.housing_subsidy_admin_contacts
    self.ssp_contacts = program.ssp_contacts
    self.hsp_contacts = program.hsp_contacts
    self.do_contacts = program.do_contacts
  end

  def save
    return unless valid?

    program.class.transaction do
      ProgramContact.where(program_id: program.id).delete_all

      shelter_agency_contact_ids.each do |id|
        ProgramContact.create(shelter_agency: true, contact_id: id, program_id: program.id)
      end
      client_contact_ids.each do |id|
        ProgramContact.create(client: true, contact_id: id, program_id: program.id)
      end
      dnd_staff_contact_ids.each do |id|
        ProgramContact.create(dnd_staff: true, contact_id: id, program_id: program.id)
      end
      housing_subsidy_admin_contact_ids.each do |id|
        ProgramContact.create(housing_subsidy_admin: true, contact_id: id, program_id: program.id)
      end
      ssp_contact_ids.each do |id|
        ProgramContact.create(ssp: true, contact_id: id, program_id: program.id)
      end
      hsp_contact_ids.each do |id|
        ProgramContact.create(hsp: true, contact_id: id, program_id: program.id)
      end
      do_contact_ids.each do |id|
        ProgramContact.create(do: true, contact_id: id, program_id: program.id)
      end

      return true
    end
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

  def available_contacts_method_for input_name
    ProgramContact.available_contact_method_for(input_name)
  end

  def selected_contacts_method_for input_name
    ProgramContact.selected_contact_method_for(input_name)
  end
end
