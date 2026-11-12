###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MatchContacts', type: :request do
  let(:route) { create(:default_route) }
  let(:editor) { create(:user) }
  let(:editor_role) { create(:role, can_edit_match_contacts: true, can_participate_in_matches: true) }
  let(:own_match) { create(:client_opportunity_match, match_route: route) }
  let(:other_match) { create(:client_opportunity_match, match_route: route) }
  let(:other_contact) { create(:contact) }
  let!(:other_join) do
    ClientOpportunityMatchContact.create!(match: other_match, contact: other_contact, dnd_staff: true, contact_order: 1)
  end
  let(:new_contact) { create(:contact) }
  let!(:own_join) do
    ClientOpportunityMatchContact.create!(match: own_match, contact: editor.contact, dnd_staff: true)
  end

  before do
    editor.roles << editor_role
  end

  def editor_rows_on(match)
    ClientOpportunityMatchContact.where(match_id: match.id, contact_id: editor.contact.id)
  end

  context 'when signed in with can_edit_match_contacts but not on the match' do
    before { sign_in editor }

    it 'returns 404 on edit without rendering the match contacts' do
      get edit_match_contacts_path(other_match)

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(other_contact.email)
    end

    it 'returns 404 on update and does not add the editor to the match' do
      patch match_contacts_path(other_match), params: { match_contacts: { dnd_staff_contact_ids: [editor.contact.id] } }

      expect(response).to have_http_status(:not_found)
      expect(editor_rows_on(other_match).count).to eq(0)
      expect(other_match.reload.dnd_staff_contact_ids).to contain_exactly(other_contact.id)
    end

    it 'returns 404 on reorder and leaves the contact order unchanged' do
      post reorder_match_contacts_path(other_match), params: { join_contact: other_join.id, order_number: 2 }

      expect(response).to have_http_status(:not_found)
      expect(other_join.reload.contact_order).to eq(1)
    end

    it 'returns 404 on update through the notification-prefixed route' do
      notification = Notifications::ProviderOnly::HsaAcceptsClient.create!(match: other_match, recipient: other_contact)

      patch notification_match_contacts_path(notification, other_match),
            params: { match_contacts: { dnd_staff_contact_ids: [editor.contact.id] } }

      expect(response).to have_http_status(:not_found)
      expect(editor_rows_on(other_match).count).to eq(0)
    end

    it 'updates contacts on a match the editor is a contact on' do
      patch match_contacts_path(own_match),
            params: { match_contacts: { dnd_staff_contact_ids: [editor.contact.id, new_contact.id] } }

      expect(response).to redirect_to(match_path(own_match))
      expect(own_match.reload.dnd_staff_contact_ids).to contain_exactly(editor.contact.id, new_contact.id)
    end

    it 'reorders contacts on a match the editor is a contact on' do
      primary_join = ClientOpportunityMatchContact.create!(match: own_match, contact: new_contact, dnd_staff: true, contact_order: 1)

      post reorder_match_contacts_path(own_match), params: { join_contact: own_join.id, order_number: 1 }

      expect(response).to redirect_to(match_path(own_match))
      expect(own_join.reload.contact_order).to eq(1)
      expect(primary_join.reload.contact_order).to be_nil
    end
  end

  context 'when signed in as an HSA contact on a route where HSAs can edit contacts' do
    let(:hsa) { create(:user) }
    let(:hsa_match) { create(:client_opportunity_match, match_route: route) }
    let(:dnd_contact) { create(:contact) }

    before do
      route.update!(contacts_editable_by_hsa: true)
      hsa.roles << create(:role, can_participate_in_matches: true)
      ClientOpportunityMatchContact.create!(match: hsa_match, contact: hsa.contact, housing_subsidy_admin: true)
      ClientOpportunityMatchContact.create!(match: hsa_match, contact: dnd_contact, dnd_staff: true)
      sign_in hsa
    end

    it 'updates HSA contacts, keeps the HSA on the match, and ignores other contact types' do
      patch match_contacts_path(hsa_match),
            params: {
              match_contacts: {
                housing_subsidy_admin_contact_ids: [new_contact.id],
                dnd_staff_contact_ids: [new_contact.id],
              },
            }

      expect(response).to redirect_to(match_path(hsa_match))
      hsa_match.reload
      expect(hsa_match.housing_subsidy_admin_contact_ids).to contain_exactly(hsa.contact.id, new_contact.id)
      expect(hsa_match.dnd_staff_contact_ids).to contain_exactly(dnd_contact.id)
    end
  end

  context 'when signed in as a user who can view all matches' do
    let(:admin) { create(:user) }

    before do
      admin.roles << create(:admin_role)
      sign_in admin
    end

    it 'updates contacts on a match the admin is not a contact on' do
      patch match_contacts_path(other_match),
            params: { match_contacts: { dnd_staff_contact_ids: [other_contact.id, new_contact.id] } }

      expect(response).to redirect_to(match_path(other_match))
      expect(other_match.reload.dnd_staff_contact_ids).to contain_exactly(other_contact.id, new_contact.id)
    end
  end
end
