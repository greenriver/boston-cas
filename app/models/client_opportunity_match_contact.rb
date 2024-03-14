###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientOpportunityMatchContact < ApplicationRecord
  # join model that represents the dedicated contact list for an
  # individual match.  These are automatically generated by the system
  # when the match was created and can be reviewed and updated by DND staff

  belongs_to :match, class_name: 'ClientOpportunityMatch', inverse_of: :client_opportunity_match_contacts
  belongs_to :contact, inverse_of: :client_opportunity_match_contacts

  include ContactJoinModel

  acts_as_paranoid

  def self.text_search(text)
    return none unless text.present?

    contact_matches = Contact.where(
      Contact.arel_table[:id].eq(arel_table[:contact_id])
    ).text_search(text).arel.exists

    where(contact_matches)
  end

end
