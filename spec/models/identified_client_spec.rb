# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiedClient, type: :model do
  it_behaves_like 'client core visibility and editability',
                  :identified_client,
                  :can_manage_all_identified_clients,
                  :can_manage_identified_clients,
                  :can_enter_identified_clients
end
