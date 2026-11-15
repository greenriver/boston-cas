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

    context 'when the voucher is unavailable and its only match is active but closed unsuccessfully' do
      before(:each) do
        user.roles << editor_role
        create(:client_opportunity_match, opportunity: voucher.opportunity, active: true, closed: true, closed_reason: 'rejected')
      end

      it 'refuses to archive and redirects to the vouchers index with an error flash' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(flash[:error]).to eq('Vouchers cannot be archived if there is an active match')
        expect(voucher.reload.archived_at).to be_nil
      end
    end

    context 'when the voucher is already archived' do
      let(:archived_time) { 2.days.ago.change(usec: 0) }

      before(:each) do
        user.roles << editor_role
        voucher.update_column(:archived_at, archived_time)
      end

      it 'refuses to archive again and leaves archived_at unchanged' do
        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(flash[:error]).to eq('Voucher is already archived')
        expect(voucher.reload.archived_at).to eq(archived_time)
      end

      it 'reports the voucher as already archived even when it is also available' do
        voucher.update_column(:available, true)

        patch archive_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(flash[:error]).to eq('Voucher is already archived')
        expect(voucher.reload.archived_at).to eq(archived_time)
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

  describe 'DELETE unavailable' do
    before(:each) do
      user.roles << create(:role, can_view_vouchers: true, can_view_programs: true, can_reject_matches: true)
    end

    context 'when the voucher has an active match' do
      let!(:voucher) do
        create(:voucher, sub_program: sub_program, available: false).tap do |v|
          v.create_opportunity!(available: true, available_candidate: false)
        end
      end
      let!(:match) { create(:client_opportunity_match, opportunity: voucher.opportunity, active: true, closed: false) }

      it 'deletes the active match, marks the voucher unavailable, and redirects to the vouchers index' do
        delete unavailable_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(ClientOpportunityMatch.exists?(match.id)).to be(false)
        expect(voucher.reload.available).to be(false)
        expect(voucher.opportunity.available).to be(false)
      end
    end

    context 'when the voucher has no opportunity' do
      let!(:voucher) { create(:voucher, sub_program: sub_program, available: false) }
      let(:flash_message) { 'The selected voucher does not have an active match, and cannot be stopped.' }

      it 'redirects to the vouchers index with an error flash' do
        delete unavailable_program_sub_program_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(vouchers_index_path)
        expect(flash[:error]).to eq(flash_message)
      end

      it 'redirects to the in-progress vouchers index with an error flash when sent to the in-progress route' do
        delete unavailable_program_sub_program_in_progress_voucher_path(program, sub_program, voucher)

        expect(response).to redirect_to(program_sub_program_in_progress_vouchers_path(program, sub_program))
        expect(flash[:error]).to eq(flash_message)
      end
    end
  end

  describe 'GET vouchers index controls' do
    # Ids of the vouchers that have a form row, taken from the id field each row's fields_for emits.
    let(:rendered_voucher_ids) do
      page.css('input[type=hidden]').
        select { |input| input['name'].to_s.match?(/\Asub_program\[vouchers_attributes\]\[\d+\]\[id\]\z/) }.
        map { |input| input['value'].to_i }
    end
    let(:page) { Nokogiri::HTML(response.body) }

    def delete_link(voucher)
      page.css(%(a[data-method="delete"][href="#{program_sub_program_voucher_path(program, sub_program, voucher)}"]))
    end

    def archive_link(voucher)
      page.css(%(a[data-method="patch"][href="#{archive_program_sub_program_voucher_path(program, sub_program, voucher)}"]))
    end

    def restore_link(voucher)
      page.css(%(a[data-method="patch"][href="#{restore_program_sub_program_archived_voucher_path(program, sub_program, voucher)}"]))
    end

    def update_button
      page.css('input[type=submit][value="Update Vouchers"]')
    end

    describe 'on the available/unmatched tab' do
      let(:tab_path) { program_sub_program_vouchers_path(program, sub_program) }
      let!(:archivable_voucher) do
        create(:voucher, sub_program: sub_program, available: false).tap do |v|
          opportunity = v.create_opportunity!(available: false, available_candidate: false)
          create(:client_opportunity_match, opportunity: opportunity, active: false, closed: true, closed_reason: 'canceled')
        end
      end
      let!(:deletable_voucher) { create(:voucher, sub_program: sub_program, available: true) }

      context 'without can_edit_vouchers' do
        before(:each) do
          user.roles << view_only_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(archivable_voucher.id, deletable_voucher.id)
        end

        it 'omits the Delete link' do
          expect(delete_link(deletable_voucher)).to be_empty
        end

        it 'omits the Archive link' do
          expect(archive_link(archivable_voucher)).to be_empty
        end

        it 'omits the Update Vouchers button' do
          expect(update_button).to be_empty
        end
      end

      context 'with can_edit_vouchers' do
        before(:each) do
          user.roles << editor_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(archivable_voucher.id, deletable_voucher.id)
        end

        it 'shows the Delete link for a voucher with no matches' do
          expect(delete_link(deletable_voucher).size).to eq(1)
        end

        it 'shows the Archive link for an unavailable voucher with only a closed match' do
          expect(archive_link(archivable_voucher).size).to eq(1)
        end

        it 'shows the Update Vouchers button' do
          expect(update_button.size).to eq(1)
        end
      end
    end

    describe 'on the archived tab' do
      let(:tab_path) { program_sub_program_archived_vouchers_path(program, sub_program) }
      let!(:archived_voucher) do
        create(:voucher, sub_program: sub_program, available: false, archived_at: 1.day.ago).tap do |v|
          opportunity = v.create_opportunity!(available: false, available_candidate: false)
          create(:client_opportunity_match, opportunity: opportunity, active: false, closed: true, closed_reason: 'canceled')
        end
      end

      context 'without can_edit_vouchers' do
        before(:each) do
          user.roles << view_only_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(archived_voucher.id)
        end

        it 'omits the Restore link' do
          expect(restore_link(archived_voucher)).to be_empty
        end

        it 'omits the Update Vouchers button' do
          expect(update_button).to be_empty
        end
      end

      context 'with can_edit_vouchers' do
        before(:each) do
          user.roles << editor_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(archived_voucher.id)
        end

        it 'shows the Restore link' do
          expect(restore_link(archived_voucher).size).to eq(1)
        end

        it 'shows the Update Vouchers button' do
          expect(update_button.size).to eq(1)
        end
      end
    end

    describe 'on the in-progress tab' do
      let(:tab_path) { program_sub_program_in_progress_vouchers_path(program, sub_program) }
      let!(:matched_voucher) do
        create(:voucher, sub_program: sub_program, available: true).tap do |v|
          opportunity = v.create_opportunity!(available: false, available_candidate: false)
          create(:client_opportunity_match, opportunity: opportunity, active: true, closed: false)
        end
      end

      context 'without can_edit_vouchers' do
        before(:each) do
          user.roles << view_only_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(matched_voucher.id)
        end

        it 'omits the Update Vouchers button' do
          expect(update_button).to be_empty
        end
      end

      context 'with can_edit_vouchers' do
        before(:each) do
          user.roles << editor_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(matched_voucher.id)
        end

        it 'shows the Update Vouchers button' do
          expect(update_button.size).to eq(1)
        end
      end
    end

    describe 'on the successful tab' do
      let(:tab_path) { program_sub_program_successful_vouchers_path(program, sub_program) }
      let!(:successful_voucher) do
        create(:voucher, sub_program: sub_program, available: false).tap do |v|
          opportunity = v.create_opportunity!(available: false, available_candidate: false)
          create(:client_opportunity_match, opportunity: opportunity, active: false, closed: true, closed_reason: 'success')
        end
      end
      let!(:canceled_voucher) do
        create(:voucher, sub_program: sub_program, available: false).tap do |v|
          opportunity = v.create_opportunity!(available: false, available_candidate: false)
          create(:client_opportunity_match, opportunity: opportunity, active: false, closed: true, closed_reason: 'canceled')
        end
      end

      context 'without can_edit_vouchers' do
        before(:each) do
          user.roles << view_only_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(successful_voucher.id)
        end

        it 'omits the Archive link' do
          expect(archive_link(successful_voucher)).to be_empty
        end

        it 'omits the Update Vouchers button' do
          expect(update_button).to be_empty
        end
      end

      context 'with can_edit_vouchers' do
        before(:each) do
          user.roles << editor_role
          get tab_path
          expect(rendered_voucher_ids).to contain_exactly(successful_voucher.id)
        end

        it 'shows the Archive link' do
          expect(archive_link(successful_voucher).size).to eq(1)
        end

        it 'shows the Update Vouchers button' do
          expect(update_button.size).to eq(1)
        end
      end
    end
  end
end
