class AddContactOrderToContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :client_opportunity_match_contacts, :contact_order, :integer
    
    # Set contact_order to 1 for all single contact types on a match
    [
      :dnd_staff,
      :housing_subsidy_admin,
      :client,
      :housing_search_worker,
      :shelter_agency,
      :ssp,
      :hsp,
      :do,
    ].each do |type|
      match_ids = ClientOpportunityMatchContact.select(:match_id).where(type => true).group(:match_id).having('count(*) = 1').pluck(:match_id)
      ClientOpportunityMatchContact.where(match_id: match_ids, type => type).update_all(contact_order: 1)
    end
  end
end
