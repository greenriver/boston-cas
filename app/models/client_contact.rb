###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ClientContact < ApplicationRecord

  belongs_to :client, inverse_of: :client_contacts
  belongs_to :contact, inverse_of: :client_contacts

  acts_as_paranoid
  has_paper_trail

end
