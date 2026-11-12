###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Requirement manager rules card', type: :request do
  let(:user) { create(:user) }
  let(:rule) { create(:bedroom_exact) }
  let(:other_rule) { create(:veteran) }

  before do
    user.roles = [role]
    sign_in user
  end

  def rules_card
    Nokogiri::HTML(response.body).at_xpath("//div[contains(@class, 'c-card')][h3[normalize-space() = 'Rules']]")
  end

  def card_rows
    rules_card.css('table tbody tr').map { |tr| tr.css('td').map { |td| td.text.squish } }
  end

  shared_examples 'rules listed read-only' do |positive:, expected_row:|
    context 'without can_assign_requirements' do
      let(:role) { create(:role, **minimal_role_attributes) }

      before do
        requirement_owner.requirements.create!(rule: rule, positive: positive, variable: '2')
        create(:requirement, requirer: other_owner, rule: other_rule, positive: true)
      end

      it "lists only this record's rule with its badge and value, and no editor" do
        get edit_path

        expect(response).to have_http_status(:ok)
        expect(card_rows).to contain_exactly(expected_row)
        expect(rules_card.to_html).not_to include('requirements_attributes')
        expect(rules_card.text).not_to include('+ Add Rule')
      end
    end

    context 'with can_assign_requirements' do
      let(:role) { create(:role, **minimal_role_attributes, can_assign_requirements: true) }

      before { requirement_owner.requirements.create!(rule: rule, positive: positive, variable: '2') }

      it 'shows the editor with the saved rule selected' do
        get edit_path

        expect(rules_card.at_css("select[name$='[requirements_attributes][0][rule_id]'] option[selected]")['value']).to eq(rule.id.to_s)
        expect(rules_card.text).to include('+ Add Rule')
        expect(card_rows).to be_empty
      end
    end
  end

  describe 'voucher edit (no inherited rules)' do
    let(:sub_program) { create(:sub_program) }
    let(:requirement_owner) { create(:voucher, sub_program: sub_program) }
    let(:other_owner) { create(:voucher, sub_program: sub_program) }
    let(:minimal_role_attributes) { { can_view_vouchers: true, can_edit_vouchers: true, can_edit_voucher_rules: true } }
    let(:edit_path) { edit_program_sub_program_voucher_path(sub_program.program, sub_program, requirement_owner) }

    it_behaves_like 'rules listed read-only', positive: true, expected_row: ['Must', 'have Bedroom exact (Two)']

    context 'when the voucher has no rules and the user lacks can_assign_requirements' do
      let(:role) { create(:role, **minimal_role_attributes) }

      it 'shows (none) in the card' do
        create(:requirement, requirer: other_owner, rule: other_rule, positive: true)

        get edit_path

        expect(rules_card.at_css('.c-card__content').text.squish).to eq('(none)')
      end
    end
  end

  describe 'building edit (inherited rules shown)' do
    let(:requirement_owner) { create(:building, name: 'Old Name') }
    let(:other_owner) { create(:building) }
    let(:minimal_role_attributes) { { can_view_buildings: true, can_edit_buildings: true } }
    let(:edit_path) { edit_building_path(requirement_owner) }

    it_behaves_like 'rules listed read-only', positive: false, expected_row: ["Can't", 'have Bedroom exact (Two)']

    context 'when a failed save re-renders the form for a user without can_assign_requirements' do
      let(:role) { create(:role, **minimal_role_attributes) }

      it 'lists only the stored rule, not rules posted in the request' do
        requirement_owner.requirements.create!(rule: rule, positive: true, variable: '2')

        patch building_path(requirement_owner), params: {
          building: {
            name: '',
            requirements_attributes: [{ 'rule_id' => other_rule.id.to_s, 'positive' => 'true' }],
          },
        }

        expect(response).to have_http_status(:ok)
        expect(card_rows).to contain_exactly(['Must', 'have Bedroom exact (Two)'])
      end
    end
  end

  describe 'admin user edit (rules grant client access)' do
    let(:requirement_owner) { create(:user) }
    let(:other_owner) { create(:user) }
    let(:minimal_role_attributes) { { can_edit_users: true } }
    let(:edit_path) { edit_admin_user_path(requirement_owner) }

    it_behaves_like 'rules listed read-only', positive: true, expected_row: ['Must', 'have Bedroom exact (Two)']
  end

  describe 'unit edit' do
    let(:requirement_owner) { create(:unit, building: create(:building)) }
    let(:role) { create(:role, can_view_units: true, can_edit_units: true) }

    it "uses the rule's alternate name" do
      rule.update!(alternate_name: 'Has exactly this many bedrooms')
      requirement_owner.requirements.create!(rule: rule, positive: true, variable: '2')

      get edit_unit_path(requirement_owner)

      expect(card_rows).to contain_exactly(['Must', 'Has exactly this many bedrooms (Two)'])
    end
  end
end
