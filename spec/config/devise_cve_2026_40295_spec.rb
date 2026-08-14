###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression coverage for CVE-2026-40295 (GHSA-jp94-3292-c3xv): both methods must
# resolve an external referrer down to a local path before using it as a redirect target.
RSpec.describe 'Devise session-timeout redirect' do
  describe Devise::Controllers::StoreLocation, '#extract_path_from_location' do
    let(:host) do
      Class.new { include Devise::Controllers::StoreLocation }.new
    end

    def extract(location)
      host.send(:extract_path_from_location, location)
    end

    it 'returns nil for nil input' do
      expect(extract(nil)).to be_nil
    end

    it 'strips an external HTTPS host, returning only the path' do
      expect(extract('https://evil.com/dashboard')).to eq('/dashboard')
    end

    it 'strips an external HTTP host' do
      expect(extract('http://evil.com/some/path')).to eq('/some/path')
    end

    it 'preserves the query string after stripping the host' do
      expect(extract('https://evil.com/path?foo=bar')).to eq('/path?foo=bar')
    end

    it 'preserves the fragment after stripping the host' do
      expect(extract('https://evil.com/path#anchor')).to eq('/path#anchor')
    end

    it 'passes a relative path through unchanged' do
      expect(extract('/local/path')).to eq('/local/path')
    end

    it 'returns nil for an invalid URI' do
      expect(extract('not a uri!!!://garbage')).to be_nil
    end
  end

  describe Devise::FailureApp, '#redirect_url' do
    let(:failure_app) do
      app = Devise::FailureApp.new
      allow(app).to receive_messages(
        warden_message: warden_msg,
        is_flashing_format?: false,
        scope_url: '/users/sign_in',
        request: mock_request,
      )
      app
    end

    let(:mock_request) { double('request', get?: get_request, referrer: referrer) }
    let(:warden_msg) { :timeout }
    let(:get_request) { false }
    let(:referrer) { 'https://evil.com/dashboard' }

    context 'when session times out on a non-GET request' do
      context 'with an external referrer' do
        it 'strips the host and returns only the local path' do
          expect(failure_app.send(:redirect_url)).to eq('/dashboard')
        end

        it 'does not include the referring domain in the redirect target' do
          expect(failure_app.send(:redirect_url)).not_to include('evil.com')
        end

        it 'does not return a full URL that would redirect off-site' do
          expect(failure_app.send(:redirect_url)).not_to match(/\Ahttps?:\/\//)
        end
      end

      context 'with a same-site referrer' do
        let(:referrer) { 'https://myapp.example.com/clients/42' }

        it 'strips the host and returns the local path' do
          expect(failure_app.send(:redirect_url)).to eq('/clients/42')
        end
      end

      context 'with a nil referrer (no Referer header sent)' do
        let(:referrer) { nil }

        it 'falls back to scope_url' do
          expect(failure_app.send(:redirect_url)).to eq('/users/sign_in')
        end
      end

      context 'with a referrer that includes a query string' do
        let(:referrer) { 'https://evil.com/search?q=payload' }

        it 'preserves the query string but strips the host' do
          expect(failure_app.send(:redirect_url)).to eq('/search?q=payload')
        end
      end
    end

    context 'when session times out on a GET request' do
      let(:get_request) { true }
      let(:referrer) { nil }

      before do
        allow(failure_app).to receive(:attempted_path).and_return('/intended/destination')
      end

      it 'uses attempted_path rather than the referrer' do
        expect(failure_app.send(:redirect_url)).to eq('/intended/destination')
      end
    end

    context 'when the warden message is not :timeout' do
      let(:warden_msg) { :unauthenticated }

      it 'ignores the referrer entirely and returns scope_url' do
        expect(failure_app.send(:redirect_url)).to eq('/users/sign_in')
      end
    end
  end
end
