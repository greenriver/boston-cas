# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrioritizedClientsExporter, type: :model do
  let(:match_route) { MatchRoutes::Default.create! }
  let(:program) { create(:program, match_route: match_route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:opportunity) { create(:opportunity, sub_program: sub_program) }
  let(:active_matches) { create_list(:client, 2) }
  let(:available_matches) { create_list(:client, 2) }

  describe '#client_name' do
    subject { exporter.send(:client_name, client, view_type: :view) }

    let(:client) { create(:client) }
    let!(:match) { create(:client_opportunity_match, client: client, opportunity: opportunity) }

    context 'with a user who can view confidential information' do
      let(:user) { create(:user) }
      let(:role) { create(:role, can_view_client_confidentiality: true, can_view_all_clients: true) }
      let(:exporter) { described_class.new(active_matches: active_matches, available_matches: available_matches, opportunity: opportunity, current_user: user, confidential_override: true) }

      before do
        user.roles << role
      end

      context 'when client is confidential' do
        before do
          client.update(confidential: true)
          client.reload
        end
        it { is_expected.to eq(client.name) }
      end

      context 'when opportunity is confidential' do
        before { program.update(confidential: true) }
        it { is_expected.to eq(client.name) }
      end
    end

    context 'with a user who cannot view confidential information' do
      let(:user) { create(:user) }
      let(:exporter) { described_class.new(active_matches: active_matches, available_matches: available_matches, opportunity: opportunity, current_user: user) }

      context 'when client is confidential' do
        before { client.update(confidential: true) }
        it { is_expected.to include('(name withheld') }
      end

      context 'when opportunity is confidential' do
        before { program.update(confidential: true) }
        it { is_expected.to include('(name withheld') }
      end

      context 'when client has no housing release' do
        before do
          allow(client).to receive(:has_full_housing_release?).and_return(false)
        end
        it { is_expected.to include('(name withheld') }
      end
    end
  end
end
