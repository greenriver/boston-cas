###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Voucher archive and unavailable actions', type: :request do
  let!(:contact) { create :macbeth }
  let!(:user) { create :user, contact: contact }
  let(:program) { create :program }
  let(:sub_program) { create :sub_program, program: program }
  let(:vouchers_index_path) { program_sub_program_vouchers_path(program, sub_program) }
  let(:view_only_role) { create :role, can_view_vouchers: true, can_view_programs: true }
  let(:editor_role) { create :role, can_view_vouchers: true, can_view_programs: true, can_edit_vouchers: true }

  before(:each) do
    sign_in user
  end

  describe 'PATCH archive' do
    let!(:voucher) do
      create(:voucher, sub_program: sub_program, available: false).tap do |v|
        v.create_opportunity!(available: false, available_candidate: false)
      end
    end

    context 'without can_edit_vouchers' do
      before(:each) { user.roles << view_only_role }

      it 'redirects to root and leaves the voucher unarchived' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(root_path)
        expect(voucher.reload.archived_at).to be_nil
      end
    end

    context 'with can_edit_vouchers' do
      before(:each) { user.roles << editor_role }

      it 'archives the voucher and redirects to the vouchers index' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(voucher.reload.archived_at).to be_within(1.minute).of(Time.current)
      end
    end

    context 'when the voucher has no opportunity' do
      let!(:voucher) { create(:voucher, sub_program: sub_program, available: false) }

      before(:each) { user.roles << editor_role }

      it 'archives the voucher and redirects to the vouchers index' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(voucher.reload.archived_at).to be_within(1.minute).of(Time.current)
      end
    end

    context 'when the voucher is unavailable but its opportunity has an active match' do
      before(:each) do
        user.roles << editor_role
        create(:client_opportunity_match, opportunity: voucher.opportunity, active: true, closed: false)
      end

      it 'refuses to archive and redirects to the vouchers index with an error flash' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(flash[:error]).to eq('Vouchers cannot be archived if there is an active match')
        expect(voucher.reload.archived_at).to be_nil
      end
    end

    context 'when the voucher is available' do
      before(:each) do
        user.roles << editor_role
        voucher.update_column(:available, true)
      end

      it 'refuses to archive and redirects to the vouchers index with an error flash' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(flash[:error]).to eq('Vouchers must be unavailable to be archived')
        expect(voucher.reload.archived_at).to be_nil
      end
    end
  end

  describe 'DELETE unavailable on a voucher with an active match' do
    let!(:voucher) do
      create(:voucher, sub_program: sub_program, available: false).tap do |v|
        v.create_opportunity!(available: true, available_candidate: false)
      end
    end
    let!(:match) { create(:client_opportunity_match, opportunity: voucher.opportunity, active: true, closed: false) }

    before(:each) do
      user.roles << create(:role, can_view_vouchers: true, can_view_programs: true, can_reject_matches: true)
    end

    it 'deletes the active match, marks the voucher unavailable, and redirects to the vouchers index' do
      delete unavailable_program_sub_program_voucher_path(program, sub_program, voucher)

      expect(response).to redirect_to(vouchers_index_path)
      expect(ClientOpportunityMatch.exists?(match.id)).to be(false)
      expect(voucher.reload.available).to be(false)
      expect(voucher.opportunity.available).to be(false)
    end
  end

  describe 'DELETE unavailable on a voucher with no opportunity' do
    let!(:voucher) { create(:voucher, sub_program: sub_program, available: false) }
    let(:flash_message) { 'The selected voucher does not have an active match, and cannot be stopped.' }

    before(:each) do
      user.roles << create(:role, can_view_vouchers: true, can_view_programs: true, can_reject_matches: true)
    end

    it 'redirects to the vouchers index with an error flash' do
      delete unavailable_program_sub_program_voucher_path(program, sub_program, voucher)

      expect(response).to redirect_to(vouchers_index_path)
      expect(flash[:error]).to eq(flash_message)
    end

    it 'redirects to the in-progress vouchers index with an error flash' do
      delete unavailable_program_sub_program_in_progress_voucher_path(program, sub_program, voucher)

      expect(response).to redirect_to(program_sub_program_in_progress_vouchers_path(program, sub_program))
      expect(flash[:error]).to eq(flash_message)
    end
  end

  describe 'GET the vouchers index' do
    let!(:archivable_voucher) do
      create(:voucher, sub_program: sub_program, available: false).tap do |v|
        opportunity = v.create_opportunity!(available: false, available_candidate: false)
        create(:client_opportunity_match, opportunity: opportunity, active: false, closed: true, closed_reason: 'canceled')
      end
    end
    let!(:deletable_voucher) { create(:voucher, sub_program: sub_program, available: true) }
    let(:archive_path) { archive_program_sub_program_voucher_path(program, sub_program, archivable_voucher) }
    let(:delete_link_pattern) do
      /<a[^>]*data-method="delete"[^>]*href="#{Regexp.escape(program_sub_program_voucher_path(program, sub_program, deletable_voucher))}"|<a[^>]*href="#{Regexp.escape(program_sub_program_voucher_path(program, sub_program, deletable_voucher))}"[^>]*data-method="delete"/
    end

    context 'without can_edit_vouchers' do
      before(:each) do
        user.roles << view_only_role
        get vouchers_index_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/<input[^>]*type="hidden"[^>]*value="#{archivable_voucher.id}"/)
        expect(response.body).to match(/<input[^>]*type="hidden"[^>]*value="#{deletable_voucher.id}"/)
      end

      it 'omits the Archive link' do
        expect(response.body).not_to include(archive_path)
      end

      it 'omits the Delete link' do
        expect(response.body).not_to match(delete_link_pattern)
      end

      it 'omits the Update Vouchers button' do
        expect(response.body).not_to include('Update Vouchers')
      end
    end

    context 'with can_edit_vouchers' do
      before(:each) do
        user.roles << editor_role
        get vouchers_index_path
      end

      it 'shows the Archive link' do
        expect(response.body).to include(archive_path)
      end

      it 'shows the Delete link' do
        expect(response.body).to match(delete_link_pattern)
      end

      it 'shows the Update Vouchers button' do
        expect(response.body).to include('Update Vouchers')
      end
    end
  end
end
