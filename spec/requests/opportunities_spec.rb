###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Opportunities', type: :request do
  let(:user) { create(:user) }
  let(:route) { create(:default_route) }
  let(:program) { create(:program, match_route: route) }
  let(:opportunity) do
    create(:opportunity, voucher: create(:voucher, sub_program: create(:sub_program, program: program)))
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

  def alert_text
    Nokogiri::HTML(response.body).css('.alert').map(&:text).join
  end

  before do
    user.roles << role
    EntityViewPermission.create!(entity: program, agency: user.agency, editable: true)
    sign_in user
  end

  describe 'GET /opportunities/:id' do
    it 'has no link to an edit page' do
      get opportunity_path(opportunity)

      doc = Nokogiri::HTML(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(doc.css(%(a[href^="/opportunities/#{opportunity.id}"][href$="/edit"])).map { |a| a[:href] }).to be_empty
        expect(doc.css('a').map(&:text)).to include('Delete')
      end
    end
  end

  describe 'removed edit and update routes' do
    it 'returns not found for GET /opportunities/:id/edit' do
      get "/opportunities/#{opportunity.id}/edit"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for PATCH /opportunities/:id and leaves the record unchanged' do
      original = opportunity.available

      patch opportunity_path(opportunity), params: { opportunity: { available: !original } }

      aggregate_failures do
        expect(response).to have_http_status(:not_found)
        expect(opportunity.reload.available).to be(original)
      end
    end
  end

  # No data condition makes Opportunity#destroy or #restore return false, so the
  # failure is forced. The controller loads its own record, so the stub has to
  # be on any instance.
  describe 'DELETE /opportunities/:id when the delete fails' do
    before { allow_any_instance_of(Opportunity).to receive(:destroy).and_return(false) }

    it 'redirects to the opportunity and shows the error' do
      delete opportunity_path(opportunity)

      aggregate_failures do
        expect(response).to redirect_to(opportunity_path(opportunity))
        follow_redirect!
        expect(alert_text).to include("Unable to delete opportunity #{opportunity.id}.")
        expect(Opportunity.exists?(opportunity.id)).to be(true)
      end
    end
  end

  describe 'POST /opportunities/:id/restore when the restore fails' do
    before do
      opportunity.destroy
      allow_any_instance_of(Opportunity).to receive(:restore).and_return(false)
    end

    it 'redirects to the opportunity list and shows the error' do
      post opportunity_restore_path(opportunity)

      aggregate_failures do
        expect(response).to redirect_to(opportunities_path)
        follow_redirect!
        expect(alert_text).to include('Unable to restore opportunity.')
        expect(Opportunity.only_deleted.exists?(opportunity.id)).to be(true)
      end
    end
  end
end
