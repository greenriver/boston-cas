###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module RelatedDefaultContacts
  extend ActiveSupport::Concern

  def contact_scope
    # The list of contacts associated with an active login user
    # If non-user contacts should be available, use an outer join?
    Contact.active_contacts
  end

  def available_shelter_agency_contacts
    contact_scope.where.not(id: shelter_agency_contact_ids)
  end

  def available_dnd_staff_contacts
    contact_scope
      .where(user_id: User.dnd_staff)
      .where.not(id: dnd_staff_contact_ids)
  end

  def available_housing_subsidy_admin_contacts
    contact_scope.where.not(id: housing_subsidy_admin_contact_ids)
  end

  def available_ssp_contacts
    contact_scope.where.not(id: ssp_contact_ids)
  end

  def available_hsp_contacts
    contact_scope.where.not(id: hsp_contact_ids)
  end

  def available_do_contacts
    contact_scope.where.not(id: do_contact_ids)
  end

  def persisted?
    true
  end

  def shelter_agency_contacts
    Contact.find shelter_agency_contact_ids
  end

  def shelter_agency_contacts=(contacts)
    self.shelter_agency_contact_ids = contacts.map(&:id)
  end

  def dnd_staff_contacts
    Contact.find dnd_staff_contact_ids
  end

  def dnd_staff_contacts=(contacts)
    self.dnd_staff_contact_ids = contacts.map(&:id)
  end

  def housing_subsidy_admin_contacts
    Contact.find housing_subsidy_admin_contact_ids
  end

  def housing_subsidy_admin_contacts=(contacts)
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

  def ssp_contacts=(contacts)
    self.ssp_contact_ids = contacts.map(&:id)
  end

  def hsp_contacts=(contacts)
    self.hsp_contact_ids = contacts.map(&:id)
  end

  def do_contacts=(contacts)
    self.do_contact_ids = contacts.map(&:id)
  end

  def label_for(input_name)
    Contact.label_for(input_name)
  end

  def contact_type_for(input_name)
    Contact.contact_type_for(input_name)
  end
end
