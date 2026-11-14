###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Opportunities program scope', type: :request do
  let(:user) { create(:user) }
  let(:own_program_editable) { true }
  let(:route) { create(:default_route) }
  let(:route_tab_id) { route.title.parameterize.dasherize }
  let(:own_program) { create(:program, name: 'Own Agency Program', match_route: route) }
  let(:other_program) { create(:program, name: 'Other Agency Program', match_route: route) }
  let(:own_opportunity) do
    create(:opportunity, voucher: create(:voucher, sub_program: create(:sub_program, program: own_program)))
  end
  let(:other_opportunity) do
    create(:opportunity, voucher: create(:voucher, sub_program: create(:sub_program, program: other_program)))
  end
  let(:role) do
    create(
      :role,
      can_view_assigned_programs: true,
      can_edit_assigned_programs: true,
      can_view_opportunities: true,
      can_edit_opportunities: true,
    )
  end

  before do
    user.roles << role
    EntityViewPermission.create!(entity: own_program, agency: user.agency, editable: own_program_editable)
    own_opportunity
    other_opportunity
    sign_in user
  end

  describe 'GET /opportunities' do
    it 'lists only opportunities in visible programs' do
      get opportunities_path(tab: route_tab_id)
      expect(response.body).to include(own_program.name)
      expect(response.body).not_to include(other_program.name)
    end

    context 'when the user can view all programs' do
      let(:role) { create(:role, can_view_programs: true, can_view_opportunities: true) }

      before { EntityViewPermission.where(agency: user.agency).destroy_all }

      it 'lists opportunities in every program without agency permissions' do
        get opportunities_path(tab: route_tab_id)
        expect(response.body).to include(own_program.name)
        expect(response.body).to include(other_program.name)
      end
    end
  end

  describe 'GET /opportunities/:id' do
    it 'shows an opportunity in a visible program' do
      get opportunity_path(own_opportunity)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(own_program.name)
    end

    it 'returns not found for an opportunity in another program' do
      get opportunity_path(other_opportunity)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /opportunities/:id' do
    it 'does not update an opportunity in another program' do
      patch opportunity_path(other_opportunity), params: { opportunity: { available: false } }
      expect(response).to have_http_status(:not_found)
      expect(other_opportunity.reload.available).to be(true)
    end
  end

  describe 'DELETE /opportunities/:id' do
    it 'does not delete an opportunity in another program' do
      expect { delete opportunity_path(other_opportunity) }.not_to(change { Opportunity.where(id: other_opportunity.id).count })
      expect(response).to have_http_status(:not_found)
    end

    it 'deletes an opportunity in an editable program' do
      expect { delete opportunity_path(own_opportunity) }.to change { Opportunity.where(id: own_opportunity.id).count }.by(-1)
    end
  end

  describe 'POST /opportunities/:opportunity_id/restore' do
    it 'does not restore an opportunity in another program' do
      other_opportunity.destroy
      post opportunity_restore_path(other_opportunity)
      expect(response).to have_http_status(:not_found)
      expect(Opportunity.with_deleted.find(other_opportunity.id).deleted_at).not_to be_nil
    end

    it 'restores an opportunity in an editable program' do
      own_opportunity.destroy
      post opportunity_restore_path(own_opportunity)
      expect(response).to redirect_to(opportunities_path)
      expect(Opportunity.find_by(id: own_opportunity.id)).to eq(own_opportunity)
    end

    context 'without the opportunity edit permission' do
      let(:role) do
        create(:role, can_view_assigned_programs: true, can_edit_assigned_programs: true, can_view_opportunities: true)
      end

      it 'does not restore an opportunity' do
        own_opportunity.destroy
        post opportunity_restore_path(own_opportunity)
        expect(response).to redirect_to(root_path)
        expect(Opportunity.with_deleted.find(own_opportunity.id).deleted_at).not_to be_nil
      end
    end
  end

  context 'when the own program is visible but not editable' do
    let(:own_program_editable) { false }

    it 'shows the opportunity' do
      get opportunity_path(own_opportunity)
      expect(response).to have_http_status(:ok)
    end

    it 'updates the opportunity' do
      expect do
        patch opportunity_path(own_opportunity), params: { opportunity: { available: false } }
      end.to change { own_opportunity.reload.available }.from(true).to(false)
    end

    it 'deletes the opportunity' do
      expect { delete opportunity_path(own_opportunity) }.to change { Opportunity.where(id: own_opportunity.id).count }.by(-1)
      expect(response).to redirect_to(opportunities_path)
    end

    it 'restores the opportunity' do
      own_opportunity.destroy
      post opportunity_restore_path(own_opportunity)
      expect(response).to redirect_to(opportunities_path)
      expect(Opportunity.with_deleted.find(own_opportunity.id).deleted_at).to be_nil
    end
  end

  context 'when the role can edit but not view assigned programs' do
    let(:role) do
      create(:role, can_edit_assigned_programs: true, can_view_opportunities: true, can_edit_opportunities: true)
    end

    it 'lists the opportunity in the own program only' do
      get opportunities_path(tab: route_tab_id)
      expect(response.body).to include(own_program.name)
      expect(response.body).not_to include(other_program.name)
    end

    it 'shows the opportunity' do
      get opportunity_path(own_opportunity)
      expect(response).to have_http_status(:ok)
    end

    it 'updates the opportunity in an editable program' do
      expect do
        patch opportunity_path(own_opportunity), params: { opportunity: { available: false } }
      end.to change { own_opportunity.reload.available }.from(true).to(false)
    end

    context 'when the agency permission is not editable' do
      let(:own_program_editable) { false }

      it 'does not update the opportunity' do
        patch opportunity_path(own_opportunity), params: { opportunity: { available: false } }
        expect(response).to have_http_status(:not_found)
        expect(own_opportunity.reload.available).to be(true)
      end
    end
  end

  describe 'POST /opportunities/:opportunity_id/contacts' do
    let(:role) do
      create(
        :role,
        can_view_assigned_programs: true,
        can_view_opportunities: true,
        can_view_contacts: true,
        can_edit_contacts: true,
      )
    end
    let(:contact) { create(:contact) }

    it 'does not link a contact to an opportunity in another program' do
      expect do
        post opportunity_contacts_path(other_opportunity), params: { opportunity_contact: { contact_id: contact.id } }
      end.not_to change(OpportunityContact, :count)
      expect(response).to have_http_status(:not_found)
    end

    it 'links a contact to an opportunity in a visible program' do
      expect do
        post opportunity_contacts_path(own_opportunity), params: { opportunity_contact: { contact_id: contact.id } }
      end.to change { own_opportunity.opportunity_contacts.where(contact_id: contact.id).count }.by(1)
    end
  end
end
