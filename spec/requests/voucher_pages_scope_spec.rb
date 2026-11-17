###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Voucher pages program and sub-program scope', type: :request do
  let(:user) { create :user }
  let(:own_sub_program) { create :sub_program }
  let(:other_sub_program) { create :sub_program }
  let(:second_agency) { create :agency }
  let!(:own_voucher) { create :voucher, sub_program: own_sub_program, available: false, archived_at: 1.day.ago }
  let!(:other_voucher) { create :voucher, sub_program: other_sub_program, available: false, archived_at: 1.day.ago }

  def archived_path(sub_program, suffix = '')
    "/programs/#{sub_program.program_id}/sub_programs/#{sub_program.id}/archived_vouchers#{suffix}"
  end

  def grant(**role_attributes)
    user.roles << create(:role, **role_attributes)
    sign_in user
  end

  context 'with can_view_assigned_programs' do
    before(:each) do
      grant(can_view_vouchers: true, can_edit_vouchers: true, can_reject_matches: true, can_view_assigned_programs: true)
      EntityViewPermission.create!(entity: own_sub_program.program, agency: user.agency)
      EntityViewPermission.create!(entity: other_sub_program.program, agency: second_agency)
    end

    it 'lists vouchers in a sub-program the agency can view' do
      get archived_path(own_sub_program)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(program_sub_program_voucher_path(own_sub_program.program, own_sub_program, own_voucher))
    end

    it 'returns 404 for a sub-program the agency cannot view' do
      get archived_path(other_sub_program)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when the sub-program belongs to a different program than the URL' do
      get "/programs/#{own_sub_program.program_id}/sub_programs/#{other_sub_program.id}/archived_vouchers"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 and leaves the voucher archived when restoring in a sub-program the agency cannot view' do
      expect do
        patch archived_path(other_sub_program, "/#{other_voucher.id}/restore")
      end.not_to(change { other_voucher.reload.archived_at })

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 and leaves the match in place when marking unavailable in a sub-program the agency cannot view' do
      active_voucher = create :voucher, sub_program: other_sub_program
      opportunity = create :opportunity, voucher: active_voucher
      match = create :client_opportunity_match, opportunity: opportunity

      delete archived_path(other_sub_program, "/#{active_voucher.id}/unavailable")

      expect(response).to have_http_status(:not_found)
      expect(ClientOpportunityMatch.exists?(match.id)).to be true
      expect(opportunity.reload.available).to be true
    end

    it 'returns 404 and creates no vouchers when adding to a sub-program the agency cannot view' do
      expect do
        post archived_path(other_sub_program), params: { sub_program: { add_vouchers: '2' } }
      end.not_to(change { Voucher.count })

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'with can_edit_assigned_programs but not can_view_assigned_programs' do
    before(:each) do
      grant(can_view_vouchers: true, can_edit_vouchers: true, can_edit_assigned_programs: true)
      EntityViewPermission.create!(entity: own_sub_program.program, agency: user.agency, editable: true)
    end

    it 'lists vouchers in a sub-program the agency can edit but not view' do
      get archived_path(own_sub_program)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(program_sub_program_voucher_path(own_sub_program.program, own_sub_program, own_voucher))
    end

    it 'returns 404 for a sub-program whose program the agency can only read' do
      EntityViewPermission.create!(entity: other_sub_program.program, agency: user.agency, editable: false)

      get archived_path(other_sub_program)

      expect(response).to have_http_status(:not_found)
    end
  end

  it 'lists vouchers in any sub-program for a user who can view all programs' do
    grant(can_view_programs: true, can_view_vouchers: true, can_edit_vouchers: true)

    get archived_path(other_sub_program)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(program_sub_program_voucher_path(other_sub_program.program, other_sub_program, other_voucher))
  end

  it 'returns 404 for a user with neither program permission' do
    grant(can_view_vouchers: true)
    EntityViewPermission.create!(entity: own_sub_program.program, agency: user.agency)

    get archived_path(own_sub_program)

    expect(response).to have_http_status(:not_found)
  end

  context 'when the voucher id belongs to another sub-program' do
    let(:sub_program_a) { create :sub_program }
    let(:sub_program_b) { create :sub_program }
    let!(:voucher_b) { create :voucher, sub_program: sub_program_b, available: false, archived_at: 1.day.ago }

    before(:each) do
      grant(can_view_programs: true, can_view_vouchers: true, can_edit_vouchers: true)
    end

    it 'returns 404 and leaves the voucher archived when restoring under the other sub-program URL' do
      expect do
        patch archived_path(sub_program_a, "/#{voucher_b.id}/restore")
      end.not_to(change { voucher_b.reload.archived_at })

      expect(response).to have_http_status(:not_found)
    end

    it 'restores a voucher that belongs to the sub-program in the URL' do
      patch archived_path(sub_program_b, "/#{voucher_b.id}/restore")

      expect(voucher_b.reload.archived_at).to be_nil
      expect(response).to redirect_to(archived_path(sub_program_b))
    end

    it 'returns 404 and leaves the requirements unchanged when updating under the other sub-program URL' do
      user.roles << create(:role, can_edit_voucher_rules: true, can_assign_requirements: true)
      existing = voucher_b.requirements.create!(rule: create(:bedroom_exact), positive: true, variable: '2')

      patch "/programs/#{sub_program_a.program_id}/sub_programs/#{sub_program_a.id}/vouchers/#{voucher_b.id}",
            params: { voucher: { requirements_attributes: [
              { id: existing.id, _destroy: '1' },
              { rule_id: create(:veteran).id, positive: 'true', variable: '1' },
            ] } }

      expect(response).to have_http_status(:not_found)
      expect(voucher_b.requirements.reload.pluck(:id, :rule_id, :variable)).to eq([[existing.id, existing.rule_id, '2']])
    end

    it 'returns 404 and keeps the voucher when destroying under the other sub-program URL' do
      delete archived_path(sub_program_a, "/#{voucher_b.id}")

      expect(response).to have_http_status(:not_found)
      expect(Voucher.exists?(voucher_b.id)).to be true
    end

    it 'returns 404 and leaves the voucher unchanged when bulk_update names one from another sub-program' do
      patch archived_path(sub_program_a, '/bulk_update'),
            params: { sub_program: { vouchers_attributes: { '0' => { id: voucher_b.id, available: '1' } } } }

      expect(response).to have_http_status(:not_found)
      expect(voucher_b.reload.available).to be false
    end
  end

  context 'when an assigned-program user manages vouchers in an own sub-program' do
    let(:vouchers_path) { "/programs/#{own_sub_program.program_id}/sub_programs/#{own_sub_program.id}/vouchers" }

    before(:each) do
      grant(can_view_vouchers: true, can_edit_vouchers: true, can_view_assigned_programs: true)
      EntityViewPermission.create!(entity: own_sub_program.program, agency: user.agency)
    end

    it 'creates the requested number of vouchers and redirects to the index' do
      expect do
        post vouchers_path, params: { sub_program: { add_vouchers: '2' } }
      end.to change { own_sub_program.vouchers.count }.by(2)

      expect(response).to redirect_to(vouchers_path)
    end

    it 'destroys an unused voucher and redirects to the index' do
      unused = create :voucher, sub_program: own_sub_program

      delete "#{vouchers_path}/#{unused.id}"

      expect(Voucher.exists?(unused.id)).to be false
      expect(response).to redirect_to(vouchers_path)
    end

    it 'makes an unavailable voucher available through bulk_update and redirects to the index' do
      unavailable = create :voucher, sub_program: own_sub_program, available: false

      patch "#{vouchers_path}/bulk_update",
            params: { sub_program: { vouchers_attributes: { '0' => { id: unavailable.id, available: '1' } } } }

      expect(unavailable.reload.available).to be true
      expect(response).to redirect_to(vouchers_path)
    end
  end
end
