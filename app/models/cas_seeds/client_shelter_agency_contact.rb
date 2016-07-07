module CasSeeds
  class ClientShelterAgencyContact
    
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
      
      opportunity_ids_to_exclude = ClientContact
        .shelter_agency
        .where(contact_id: universal_contact.id)
        .pluck('DISTINCT client_id')
      
      clients = Client.where.not id: opportunity_ids_to_exclude
      Rails.logger.info "Adding shelter agency contact to #{clients.count} clients"
      
      clients.find_each do |client|
        client.shelter_agency_contacts << universal_contact
      end
    end
    
  end
end