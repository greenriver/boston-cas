###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# curl -I -s "http://hmis-url/?[1-350]" | grep HTTP/

RSpec.describe Rack::Attack, type: :request do
  let(:user) { create :user }
  let(:search_paths) do
    [
      '/client_search_queries',
      '/client_search_queries/1',
      '/unavailable_client_search_queries',
      '/unavailable_client_search_queries/1',
      '/deidentified_client_search_queries',
      '/deidentified_client_search_queries/1',
      '/identified_client_search_queries',
      '/identified_client_search_queries/1',
      '/imported_client_search_queries',
      '/imported_client_search_queries/1',
    ]
  end

  let(:read_paths) { search_paths.select { |path| path.include?('/1') } }
  let(:write_paths) { search_paths.reject { |path| path.include?('/1') } }

  before(:all) do
    Rack::Attack.enabled = true
  end

  after(:all) do
    Rack::Attack.enabled = false
  end

  # request a path repeatedly and return
  # the request number when it returns `throttled_status`
  # @param requests_to_send [Integer] how many requests to send before giving up
  # @param throttled_status [Integer] stop when we encounter this status
  # @param mode [Symbol] default
  def till_throttled(requests_to_send:, throttled_status: 429, mode: :default, &block)
    requests_sent = 0
    status_encountered = false

    case mode
    when :slow
      time_advance = 1
    when :default
      time_advance = 0.01
    else
      raise 'unknown mode'
    end

    begin
      (requests_to_send + 1).times do |cnt|
        # travel to hour boundary so we always start at 00:00, manually advancing time every loop
        travel_to(Time.current.beginning_of_hour + (cnt * time_advance).seconds) unless time_advance.zero?
        block.arity == 1 ? yield(cnt) : yield
        requests_sent += 1
        status_encountered = response.status == throttled_status
        break if status_encountered
      end
    ensure
      travel_back
    end
    status_encountered ? requests_sent - 1 : nil
  end

  shared_examples 'blocks active storage routes' do
    let(:active_storage_paths) do
      [
        '/rails/active_storage/blobs/redirect/fake-signed-id/file.jpg',
        '/rails/active_storage/representations/redirect/fake-signed-id/file.jpg',
        '/rails/active_storage/disk/fake-key/file.jpg',
      ]
    end

    it 'returns 403 for all Active Storage endpoints' do
      active_storage_paths.each do |path|
        get path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  before(:each) do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  describe 'when not-logged in' do
    include_examples 'blocks active storage routes'
    describe 'when hitting the homepage' do
      let(:path) { root_path }

      it 'throttle burst requests' do
        throttled_at = 10
        requests_sent = till_throttled(requests_to_send: throttled_at) { get(path) }
        expect(requests_sent).to eq(throttled_at)
      end
    end

    describe 'and posting to the sign-in page' do
      let(:path) { user_session_path }
      it 'throttles brute-force requests' do
        throttled_at = 20
        requests_sent = till_throttled(requests_to_send: throttled_at, mode: :slow) do |i|
          post(path, params: { user: { email: "test-#{i}@example.com", password: 'incorrect' } })
        end
        expect(requests_sent).to eq(throttled_at)
      end
    end

    describe 'Password Reset Throttling' do
      let(:path) { edit_user_password_path }
      it 'throttles brute-force password reset requests' do
        throttled_at = 20
        requests_sent = till_throttled(requests_to_send: throttled_at, mode: :slow) do |i|
          get(path, params: { reset_password_token: "FFFFFFFFFFFFFFFFFFF#{i}" })
        end
        expect(requests_sent).to eq(throttled_at)
      end
    end
  end

  describe 'when logged in' do
    before do
      sign_in user
    end

    include_examples 'blocks active storage routes'

    describe 'and hitting the homepage' do
      let(:path) { root_path }

      it 'throttle excessive requests by IP address - enabled' do
        throttled_at = 150
        requests_sent = till_throttled(requests_to_send: throttled_at) { get(path) }
        expect(requests_sent).to eq(throttled_at)
      end
    end

    describe 'and creating search queries' do
      let(:path) { client_search_queries_path }

      it 'throttles excessive search query creation' do
        throttled_at = 30
        requests_sent = till_throttled(requests_to_send: throttled_at, mode: :slow) do |i|
          post(path, params: { q: "test search #{i}" })
        end
        expect(requests_sent).to eq(throttled_at)
      end
    end

    describe 'and viewing search results' do
      let(:search_query) { create(:client_search_query, created_by: user) }
      let(:path) { client_search_query_path(id: search_query.id) }

      it 'throttles excessive search result viewing' do
        throttled_at = 30
        requests_sent = till_throttled(requests_to_send: throttled_at) do
          get(path)
        end
        expect(requests_sent).to eq(throttled_at)
      end
    end
  end

  context 'system_status_requests' do
    let(:path) { '/system_status/operational' }
    let(:headers) do
      { 'HTTP_USER_AGENT' => 'ELB-HealthChecker/2.0' }
    end

    it 'does not throttle requests' do
      throttled_at = 20
      requests_sent = till_throttled(requests_to_send: throttled_at) { get(path, headers: headers) }
      expect(requests_sent).to be_nil
    end
  end

  context 'sentry notification rate limiting' do
    let(:path) { '/' }

    before do
      SentryNotificationRateLimiter.instance.reset
    end

    it 'rate limits notifications to Sentry' do
      throttled_at = 20 # throttled at 10 currently
      allow(Sentry).to receive(:capture_message)

      # Send multiple requests in quick succession
      till_throttled(requests_to_send: throttled_at, throttled_status: -999) { get(path, headers: headers) }

      # Verify that Sentry was called only once for similar events
      expect(Sentry).to have_received(:capture_message).once
    end
  end

  describe 'regex helper methods' do
    let(:request) { Rack::Attack::Request.new(env) }
    let(:env) { {} }

    describe 'regex pattern matching' do
      it 'correctly matches and rejects paths for both regex patterns' do
        aggregate_failures 'read regex tests' do
          read_paths.each do |path|
            expect(path).to match(request.client_search_query_read_regex), "Expected #{path} to match read regex"
            expect(path).not_to match(request.client_search_query_write_regex), "Expected #{path} not to match write regex"
          end
        end

        aggregate_failures 'write regex tests' do
          write_paths.each do |path|
            expect(path).to match(request.client_search_query_write_regex), "Expected #{path} to match write regex"
            expect(path).not_to match(request.client_search_query_read_regex), "Expected #{path} not to match read regex"
          end
        end
      end
    end
  end

  describe 'search query throttling with regex methods' do
    before do
      sign_in user
    end

    describe 'search query throttling' do
      it 'throttles GET requests to client_search_queries with ID' do
        aggregate_failures do
          read_paths.each_with_index do |path, index|
            # Use different IP addresses for each path to avoid cache interference
            ip_address = "192.168.1.#{index + 1}"

            requests_sent = till_throttled(requests_to_send: 30) do |i|
              get(path.gsub('1', (i + 1).to_s), headers: { 'REMOTE_ADDR' => ip_address })
            end
            expect(requests_sent).to eq(30), "Expected #{path} to be throttled for GET at 30 requests, got #{requests_sent}"
          end
        end
      end

      it 'POST requests to client_search_queries with ID return 404s' do
        aggregate_failures do
          read_paths.each_with_index do |path, index|
            # Use different IP addresses for each path to avoid cache interference
            ip_address = "192.168.2.#{index + 1}"

            till_throttled(requests_to_send: 5, mode: :slow) do |i|
              post(path.gsub('1', (i + 1).to_s), params: { q: "test search #{i}" }, headers: { 'REMOTE_ADDR' => ip_address })
            end
            expect(response.status).to eq(404), "Expected POST to #{path} to return 404, got #{response.status}"
          end
        end
      end

      it 'throttles POST requests to client_search_queries without ID' do
        aggregate_failures do
          write_paths.each_with_index do |path, index|
            # Use different IP addresses for each path to avoid cache interference
            ip_address = "192.168.2.#{index + 1}"

            requests_sent = till_throttled(requests_to_send: 30, mode: :slow) do |i|
              post(path, params: { q: "test search #{i}" }, headers: { 'REMOTE_ADDR' => ip_address })
            end
            expect(requests_sent).to eq(30), "Expected #{path} to be throttled for POST at 30 requests, got #{requests_sent}"
          end
        end
      end

      it 'does not throttle GET requests to client_search_queries without ID' do
        aggregate_failures do
          write_paths.each_with_index do |path, index|
            # Use different IP addresses for each path to avoid cache interference
            ip_address = "192.168.3.#{index + 1}"

            requests_sent = till_throttled(requests_to_send: 5) do
              get(path, headers: { 'REMOTE_ADDR' => ip_address })
            end
            expect(requests_sent).to be_nil, "Expected #{path} not to be throttled for GET"
          end
        end
      end
    end
  end
end
