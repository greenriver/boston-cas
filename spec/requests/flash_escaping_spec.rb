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
    let(:unit_marker) { '<b>unit</b>' }
    let(:escaped_unit_marker) { '&lt;b&gt;unit&lt;/b&gt;' }
    let(:building_marker) { '<b>bldg</b>' }
    let(:escaped_building_marker) { '&lt;b&gt;bldg&lt;/b&gt;' }
    let(:route) { create(:default_route) }
    let(:program) { create(:program, match_route: route) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:building) { create(:building, name: building_marker) }

    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    it 'keeps the building link and escapes both the unit and building names' do
      post program_sub_program_unit_for_building_index_path(program, sub_program),
           params: { unit_for_building: { name: unit_marker, available: true, building_id: building.id } }
      follow_redirect!

      link = Nokogiri::HTML(response.body).at_css(".alert a[href='#{building_path(building)}']")
      aggregate_failures do
        expect(link).to be_present
        expect(link.inner_html).to eq(escaped_building_marker)
        expect(flash_html).to include("Unit #{escaped_unit_marker} in ")
        expect(flash_html).not_to include(unit_marker)
        expect(flash_html).not_to include(building_marker)
      end
    end
  end

  describe 'creating a program' do
    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    it 'links to the new sub-program and escapes the program name' do
      post programs_path, params: {
        program: {
          name: marker,
          match_route_id: MatchRoutes::Default.first.id,
          sub_programs_attributes: [{ program_type: 'Sponsor-Based' }],
        },
      }
      follow_redirect!

      sub_program = Program.find_by!(name: marker).sub_programs.first
      link = Nokogiri::HTML(response.body).at_css(".alert a[href='#{edit_program_sub_program_path(sub_program.program, sub_program)}']")
      aggregate_failures do
        expect(link).to be_present
        expect(link.inner_html).to eq(escaped_marker)
        expect(flash_html).not_to include(marker)
      end
    end
  end

  describe 'updating a sub-program' do
    let(:program) { create(:program, name: marker, match_route: create(:default_route)) }
    let(:sub_program) { create(:sub_program, program: program) }

    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    it 'links to the sub-program and escapes the program name' do
      patch program_sub_program_path(program, sub_program), params: { sub_program: { name: 'Renamed', file_tag_ids: [''] } }
      follow_redirect!

      link = Nokogiri::HTML(response.body).at_css(".alert a[href='#{edit_program_sub_program_path(program, sub_program)}']")
      aggregate_failures do
        expect(link).to be_present
        expect(link.inner_html).to eq(escaped_marker)
        expect(flash_html).not_to include(marker)
      end
    end
  end

  describe 'updating a unit with invalid params' do
    let(:unit) { create(:unit, name: 'Unit A', building: create(:building)) }

    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    it 'shows the error flash on the re-rendered form' do
      patch unit_path(unit), params: { unit: { name: '' } }

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(Nokogiri::HTML(response.body).css('.alert.error').text).to include('Unable to update unit')
      end
    end

    it 'does not carry the error flash into the next request' do
      patch unit_path(unit), params: { unit: { name: '' } }
      get units_path

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(flash_html).not_to include('Unable to update unit')
      end
    end
  end

  describe 'program and sub-program form errors' do
    let(:program) { create(:program, match_route: create(:default_route)) }
    let(:sub_program) { create(:sub_program, program: program) }

    before do
      actor.roles << create(:admin_role)
      sign_in actor
    end

    def error_flash_text
      Nokogiri::HTML(response.body).css('.alert.error').text
    end

    def expect_error_only_on_rerender
      expect(response).to have_http_status(:ok)
      expect(error_flash_text).to include('Please review the form problems below.')
      get units_path
      expect(response).to have_http_status(:ok)
      expect(error_flash_text).not_to include('Please review the form problems below.')
    end

    it 'shows a program create error on the re-rendered form and not on the next page' do
      post programs_path, params: { program: { name: '', match_route_id: MatchRoutes::Default.first.id } }
      expect_error_only_on_rerender
    end

    it 'shows a sub-program create error on the re-rendered form and not on the next page' do
      post program_sub_programs_path(program), params: { sub_program: { program_type: 'Project-Based', building_id: '' } }
      expect_error_only_on_rerender
    end

    it 'shows a sub-program update error on the re-rendered form and not on the next page' do
      patch program_sub_program_path(program, sub_program), params: { sub_program: { program_type: 'Project-Based', building_id: '' } }
      expect_error_only_on_rerender
    end
  end

  describe 'updating account name and email schedule together' do
    before { sign_in actor }

    it 'renders each note on its own line in the flash' do
      patch account_path, params: { user: { first_name: 'Renamed', last_name: actor.last_name, email_schedule: 'daily' } }
      follow_redirect!

      alert = Nokogiri::HTML(response.body).at_css('.alert.notice')
      aggregate_failures do
        expect(alert.css('br').size).to eq(1)
        expect(alert.at_css('br').previous.text.strip).to eq('Account name was updated.')
        expect(alert.at_css('br').next.text.strip).to eq('Email schedule was updated.')
      end
    end
  end
end
