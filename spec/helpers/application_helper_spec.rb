###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade (audit hotspot).
#
# `menu_request_matches_generated_path?` is the app's only URL query-string
# parser (`Rack::Utils.parse_query`, application_helper.rb). Rails 8.1 removes
# legacy Action Pack semicolon/bracket query parsing, and Rack changed its
# separator handling; these specs cover the current 7.2 behavior any regressions
# in path/query comparison would surface here.
RSpec.describe ApplicationHelper, type: :helper do
  describe '#menu_request_matches_generated_path?' do
    # Drive the private helper with a stubbed request path and params, mirroring
    # how a filtered menu link is compared against the current request.
    def menu_active?(generated_path, request_path:, params: {})
      allow(helper).to receive(:request).and_return(double(path: request_path))
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(params))
      helper.send(:menu_request_matches_generated_path?, generated_path)
    end

    it 'is false when the path does not match' do
      expect(menu_active?('/clients', request_path: '/opportunities')).to be false
    end

    it 'is true when the path matches and there is no query string' do
      expect(menu_active?('/clients', request_path: '/clients')).to be true
    end

    it 'is true when every generated query key matches the current params' do
      expect(
        menu_active?('/clients?sort=name', request_path: '/clients', params: { 'sort' => 'name' }),
      ).to be true
    end

    it 'is false when a generated query value differs from the current params' do
      expect(
        menu_active?('/clients?sort=name', request_path: '/clients', params: { 'sort' => 'agency' }),
      ).to be false
    end

    it 'requires all generated keys to be present in params (extra request params are allowed)' do
      expect(
        menu_active?('/clients?sort=name', request_path: '/clients', params: { 'sort' => 'name', 'step' => '2' }),
      ).to be true
      expect(
        menu_active?('/clients?sort=name&step=2', request_path: '/clients', params: { 'sort' => 'name' }),
      ).to be false
    end

    it 'splits multiple query params on "&" (Rack 3 does not treat ";" as a separator)' do
      # `&` => two independent keys.
      expect(
        menu_active?('/clients?sort=name&step=2', request_path: '/clients', params: { 'sort' => 'name', 'step' => '2' }),
      ).to be true

      # `;` is NOT a separator on the pinned Rack 3.x: the whole "1;step=2" is the
      # value of key "a". This characterizes current behavior so a Rack/Rails bump
      # that reintroduces semicolon splitting is caught.
      expect(
        menu_active?('/clients?a=1;step=2', request_path: '/clients', params: { 'a' => '1;step=2' }),
      ).to be true
      expect(
        menu_active?('/clients?a=1;step=2', request_path: '/clients', params: { 'a' => '1', 'step' => '2' }),
      ).to be false
    end
  end
end
