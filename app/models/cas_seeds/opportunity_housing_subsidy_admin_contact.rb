module CasSeeds
  class OpportunityHousingSubsidyAdminContact
    
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
      
      opportunity_ids_to_exclude = OpportunityContact
        .housing_subsidy_admin
        .where(contact_id: universal_contact.id)
        .pluck('DISTINCT opportunity_id')
      
      opportunities = Opportunity.where.not id: opportunity_ids_to_exclude
      Rails.logger.info "Adding housing subsidy admin contact to #{opportunities.count} opportunities"
      
      opportunities.find_each do |opportunity|
        opportunity.housing_subsidy_admin_contacts << universal_contact
      end
    end
    
  end
end