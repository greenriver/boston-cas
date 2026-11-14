###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MatchProgressUpdateNotes', type: :request do
  let(:route) { create(:default_route) }
  let(:approver) { create(:user) }
  let(:approver_role) { create(:role, can_approve_matches: true, can_participate_in_matches: true) }
  let(:own_match) { create(:client_opportunity_match, match_route: route) }
  let(:other_match) { create(:client_opportunity_match, match_route: route) }
  # Random so the text can't appear in the spec source, which the test-env 404 debug page prints
  let(:original_note) { "note-#{SecureRandom.hex(8)}" }
  let!(:other_update) { create_update(match: other_match, contact: create(:contact)) }

  def create_update(match:, contact:)
    MatchProgressUpdates::Anyone.create!(
      match: match,
      contact: contact,
      note: original_note,
      response: 'Client searching for unit',
      client_last_seen: Date.current,
      submitted_at: Time.current,
    )
  end

  before do
    approver.roles << approver_role
    ClientOpportunityMatchContact.create!(match: own_match, contact: approver.contact, dnd_staff: true)
    sign_in approver
  end

  context 'with a progress update from another match' do
    it 'returns 404 on edit without rendering the note' do
      get edit_match_match_progress_update_note_path(own_match, other_update)

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(original_note)
    end

    it 'returns 404 on update and leaves the note unchanged' do
      patch match_match_progress_update_note_path(own_match, other_update), params: { update: { note: 'changed' } }

      expect(response).to have_http_status(:not_found)
      expect(other_update.reload.note).to eq(original_note)
    end

    it 'returns 404 on destroy and leaves the note unchanged' do
      delete match_match_progress_update_note_path(own_match, other_update)

      expect(response).to have_http_status(:not_found)
      expect(other_update.reload.note).to eq(original_note)
    end
  end

  context 'with a progress update on the match in the URL' do
    let!(:own_update) { create_update(match: own_match, contact: approver.contact) }

    it 'updates the note' do
      patch match_match_progress_update_note_path(own_match, own_update), params: { update: { note: 'changed' } }

      expect(response).to redirect_to(match_path(own_match))
      expect(own_update.reload.note).to eq('changed')
    end
  end
end
