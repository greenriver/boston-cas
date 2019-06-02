class Contact < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  belongs_to :user, required: false
  delegate :can_view_all_clients?, :can_edit_match_contacts?, :can_view_all_matches?, :can_reject_matches?, :can_approve_matches?, :can_reject_matches?, :can_act_on_behalf_of_match_contacts?, to: :user, allow_nil: true, prefix: true

  has_many :client_opportunity_matches
  has_many :services

  has_many :building_contacts, inverse_of: :contact, dependent: :destroy
  has_many :subgrantee_contacts, inverse_of: :contact, dependent: :destroy
  has_many :client_contacts, inverse_of: :contact, dependent: :destroy
  has_many :opportunity_contacts, inverse_of: :contact, dependent: :destroy
  has_many :program_contacts, inverse_of: :contact, dependent: :destroy
  has_many :client_opportunity_match_contacts, inverse_of: :contact, dependent: :destroy
  has_many :clients, through: :client_contacts
  has_many :buildings, through: :building_contacts
  has_many :subgrantees, through: :subgrantee_contacts

  has_many :events, class_name: MatchEvents::Base.name, inverse_of: :contact
  has_many :messages
  # for backwards compatibility on match history
  has_many :status_updates, class_name: MatchProgressUpdates::Base.name, inverse_of: :contact

  def full_name
    [first_name, last_name].compact.join " "
  end
  alias_method :name, :full_name

  def name_with_email
    "#{name} <#{email}>"
  end

  def has_user?
    user.present?
  end

  def self.text_search(text)
    return none unless text.present?

    query = "%#{text}%"
    where(
      arel_table[:first_name].matches(query)
      .or(arel_table[:last_name].matches(query))
      .or(arel_table[:email].matches(query))
      .or(arel_table[:phone].matches(query))
      .or(arel_table[:cell_phone].matches(query))
      .or(arel_table[:role].matches(query))
    )
  end

  def self.label_for(input_name)
    choices = {
      shelter_agency_contacts: "#{_('Shelter Agency')} and/or #{_('Housing Search Worker')} Contacts",
      client_contacts: "Client Contacts",
      regular_contacts: "Client Contacts",
      dnd_staff_contacts: "#{_('DND')} Staff Contacts",
      housing_subsidy_admin_contacts: "#{_('Housing Subsidy Administrator')} Contacts",
      ssp_contacts: "#{_('Stabilization Service Provider')}",
      hsp_contacts: "#{_('Housing Search Provider')}",
      do_contacts: "#{_('Development Officer Contacts')}",
    }
    choices[input_name] || input_name
  end

  def self.contact_type_for(input_name)
    choices = {
      shelter_agency_contacts: 'shelter_agency',
      client_contacts: "client",
      regular_contacts: "client",
      dnd_staff_contacts: "dnd_staff",
      housing_subsidy_admin_contacts: "housing_subsidy_admin",
      ssp_contacts: "ssp",
      hsp_contacts: "hsp",
      do_contacts: "do",
    }
    choices[input_name] || input_name
  end

end
