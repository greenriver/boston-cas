###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedClient, type: :model do
  it_behaves_like 'client core visibility and editability',
                  :deidentified_client,
                  :can_manage_all_deidentified_clients,
                  :can_manage_deidentified_clients,
                  :can_enter_deidentified_clients
end
