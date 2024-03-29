###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class ClientRegularContact

    def run!
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      full_name = "#{first_name} #{last_name}"
      email = "#{full_name.parameterize}@pretend.com"
      universal_contact = Contact.find_or_create_by! email: email do |contact|
        contact.first_name = first_name
        contact.last_name = last_name
        contact.phone = '(555) 555-5555'
      end

      client_ids_to_exclude = ClientContact
      .regular
      .where(contact_id: universal_contact.id)
      .pluck('DISTINCT client_id')

      clients = Client.where.not id: client_ids_to_exclude
      Rails.logger.info "Adding regular client contact to #{clients.count} clients"

      clients.find_each do |client|
        client.regular_contacts << universal_contact
      end
    end

  end
end
