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
end
