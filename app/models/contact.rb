###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Contact < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :user, optional: true
  delegate :can_view_all_clients?, :can_edit_match_contacts?, :can_view_all_matches?, :can_reject_matches?, :can_approve_matches?, :can_reject_matches?, :can_act_on_behalf_of_match_contacts?, to: :user, allow_nil: true, prefix: true

  has_many :client_opportunity_matches
  has_many :services

  has_many :building_contacts, inverse_of: :contact, dependent: :destroy
  has_many :subgrantee_contacts, inverse_of: :contact, dependent: :destroy
  has_many :client_contacts, inverse_of: :contact, dependent: :destroy
  has_many :opportunity_contacts, inverse_of: :contact, dependent: :destroy
  has_many :sub_program_contacts, inverse_of: :contact, dependent: :destroy
  has_many :program_contacts, inverse_of: :contact, dependent: :destroy # FIXME: remove after contacts moved to sub_program
  has_many :client_opportunity_match_contacts, inverse_of: :contact, dependent: :destroy
  has_many :clients, through: :client_contacts
  has_many :buildings, through: :building_contacts
  has_many :subgrantees, through: :subgrantee_contacts
  has_many :matches, through: :client_opportunity_match_contacts, source: :match

  has_many :events, class_name: MatchEvents::Base.name, inverse_of: :contact
  has_many :messages
  # for backwards compatibility on match history
  has_many :status_updates, class_name: MatchProgressUpdates::Base.name, inverse_of: :contact
  has_one :agency, through: :user

  validates_presence_of :first_name, :last_name, :email

  scope :active_contacts, -> do
    # The list of contacts associated with an active login user
    # If non-user contacts should be available, use an outer join?
    joins(:user).merge(User.active)
  end

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

  # Used when no more-specific context is available
  def self.label_for(input_name)
    choices = {
      shelter_agency_contacts: "#{Translation.translate('Shelter Agency')} and/or #{Translation.translate('Housing Search Worker')} Contacts",
      client_contacts: "#{Translation.translate('Client')} Contacts",
      regular_contacts: "#{Translation.translate('Client')} Contacts",
      dnd_staff_contacts: "#{Translation.translate('DND')} Staff Contacts",
      housing_subsidy_admin_contacts: "#{Translation.translate('Housing Subsidy Administrator')} Contacts",
      ssp_contacts: Translation.translate('Stabilization Service Provider'),
      hsp_contacts: Translation.translate('Housing Search Provider'),
      do_contacts: Translation.translate('Development Officer Contacts'),
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

  def phone_for_display
    phone.presence || cell_phone
  end
end
