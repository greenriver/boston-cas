###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Warehouse::Analytics::ReferralUser do
  # Warehouse models use the test_warehouse connection. CI only runs createdb for that
  # database, so analytics tables are not loaded from CAS migrations. Stubbing this model
  # still triggers ActiveRecord schema introspection on cas_analytics_referral_users.
  def ensure_warehouse_referral_users_table!
    connection = Warehouse::Base.connection
    return false if connection.data_source_exists?('cas_analytics_referral_users')

    # A primary key is enough for schema introspection; sync! behavior is stubbed below.
    connection.create_table :cas_analytics_referral_users, id: false do |t|
      t.bigint :id, null: false, primary_key: true
    end
    true
  end

  def remove_warehouse_referral_users_table!
    Warehouse::Base.connection.drop_table :cas_analytics_referral_users, if_exists: true
    described_class.reset_column_information
  end

  describe '.sync!' do
    let(:match) { instance_double(ClientOpportunityMatch, id: 42) }
    let(:match_admin) do
      instance_double(
        User,
        id: 7,
        contact: instance_double(Contact, email: 'admin@example.com'),
      )
    end
    let(:imported_batches) { [] }
    let(:hmis_match_contacts_scope) { double('hmis match contacts scope') }
    let(:active_users) { double('active users') }
    let(:match_admins) { double('match admins') }
    let(:warehouse_connection) { instance_double('Connection', execute: true) }

    before do
      @created_warehouse_referral_users_table = ensure_warehouse_referral_users_table!
      # sync! is exercised with stubs so we do not depend on warehouse data or import!.
      allow(described_class).to receive(:connection).and_return(warehouse_connection)
      allow(described_class).to receive(:quoted_table_name).and_return('cas_analytics_referral_users')
      allow(described_class).to receive(:transaction).and_yield
      allow(described_class).to receive(:new) do |**attrs|
        Struct.new(*attrs.keys, keyword_init: true).new(**attrs)
      end
      allow(described_class).to receive(:import!) do |batch|
        imported_batches << batch
      end
      allow(described_class).to receive(:maximum).with(:id).and_return(nil)

      allow(::ClientOpportunityMatchContact).to receive(:joins).
        with(contact: :user, match: { client: :project_client, opportunity: :voucher }).
        and_return(hmis_match_contacts_scope)
      allow(hmis_match_contacts_scope).to receive(:preload).with(:match, :contact).and_return(hmis_match_contacts_scope)
      allow(hmis_match_contacts_scope).to receive(:merge).with(ProjectClient.from_hmis).and_return(hmis_match_contacts_scope)
      allow(hmis_match_contacts_scope).to receive(:find_in_batches).with(batch_size: 1_000)

      allow(User).to receive(:active).and_return(active_users)
      allow(active_users).to receive(:match_admins).and_return(match_admins)
      allow(match_admins).to receive(:joins).with(:contact).and_return(match_admins)
      allow(match_admins).to receive(:preload).with(:contact).and_return(match_admins)
      allow(match_admins).to receive(:to_a).and_return([match_admin])

      allow(ClientOpportunityMatch).to receive(:find_in_batches).with(batch_size: 1_000).and_yield([match])
    end

    after do
      next unless @created_warehouse_referral_users_table

      remove_warehouse_referral_users_table!
    end

    it 'starts match admin ids at 1 when no HMIS referral users were imported' do
      expect { described_class.sync! }.not_to raise_error

      expect(imported_batches.length).to eq(1)
      expect(imported_batches.first.length).to eq(1)
      expect(imported_batches.first.first).to have_attributes(
        id: 1,
        email: 'admin@example.com',
        referral_id: 42,
        cas_user_id: 7,
      )
    end
  end
end
