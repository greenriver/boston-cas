###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Flash message escaping', type: :request do
  let(:marker) { '<b>x</b>' }
  let(:escaped_marker) { '&lt;b&gt;x&lt;/b&gt;' }
  let(:actor) { create(:user) }

  def flash_html
    Nokogiri::HTML(response.body).css('.alert').map(&:inner_html).join
  end

  describe 'ending a session' do
    let(:target) { create(:user_two, first_name: marker, last_name: 'Target') }

    before do
      actor.roles << create(:admin_role, can_manage_sessions: true)
      sign_in actor
    end

    it 'shows the name as text in the flash' do
      delete admin_session_path(target)
      follow_redirect!

      aggregate_failures do
        expect(flash_html).to include("Session ended for #{escaped_marker} Target")
        expect(flash_html).not_to include(marker)
      end
    end
  end

  describe 'creating a unit from a program' do
    let(:route) { create(:default_route) }
    let(:program) { create(:program, match_route: route) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:building) { create(:building, name: marker) }

    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    it 'keeps the building link and escapes the building name' do
      post program_sub_program_unit_for_building_index_path(program, sub_program),
           params: { unit_for_building: { name: 'U-1', available: true, building_id: building.id } }
      follow_redirect!

      link = Nokogiri::HTML(response.body).at_css(".alert a[href='#{building_path(building)}']")
      aggregate_failures do
        expect(link).not_to be_nil
        expect(link.inner_html).to eq(escaped_marker)
        expect(flash_html).not_to include(marker)
      end
    end
  end
end
