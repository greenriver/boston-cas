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

  describe '.agencies_available_to' do
    let(:own_agency) { create :agency }
    let(:other_agency) { create :agency }
    let(:role) { create :role }
    let(:user) do
      u = create(:user, agency: own_agency)
      u.roles << role
      u
    end

    before { other_agency } # ensure a second agency exists to be excluded/included

    it 'returns all agencies for a cross-agency manager' do
      role.update(can_manage_all_deidentified_clients: true)
      expect(described_class.agencies_available_to(user)).to include(own_agency, other_agency)
    end

    it 'returns only the user agency for an own-agency enterer (non-pathways)' do
      role.update(can_enter_deidentified_clients: true)
      allow(described_class).to receive(:pathways_enabled?).and_return(false)
      expect(described_class.agencies_available_to(user)).to contain_exactly(own_agency)
    end

    it 'returns all agencies for an own-agency enterer when pathways is enabled' do
      role.update(can_enter_deidentified_clients: true)
      allow(described_class).to receive(:pathways_enabled?).and_return(true)
      expect(described_class.agencies_available_to(user)).to include(own_agency, other_agency)
    end

    it 'returns no agencies for a user without de-identified permissions' do
      expect(described_class.agencies_available_to(user)).to be_empty
    end
  end
end
