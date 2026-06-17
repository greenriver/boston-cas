###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Tests the actual config/cache_store.yml by loading and evaluating it with different ENV.
# All consumers (cache store, Action Cable, ApplicationNotifier) use config_for(:cache_store).
#
# Full end-to-end verification must be confirmed manually in dev/staging.
RSpec.describe 'Redis config (cache_store.yml)' do
  def with_env(env_vars)
    originals = env_vars.keys.map { |k| [k, ENV[k]] }.to_h
    env_vars.each do |k, v|
      v.nil? ? ENV.delete(k) : ENV[k] = v
    end
    yield
  ensure
    originals.each do |k, v|
      v.nil? ? ENV.delete(k) : ENV[k] = v
    end
  end

  # Loads actual config/cache_store.yml, rendering ERB with current ENV
  def load_cache_store_config
    path = Rails.root.join('config', 'cache_store.yml')
    content = ERB.new(File.read(path)).result(binding)
    config = YAML.load(content)
    env = ENV.fetch('RAILS_ENV') { 'test' }
    (config[env] || {}).stringify_keys
  end

  describe 'redis_url resolution (cache_store.yml)' do
    it 'uses REDIS_URL when set' do
      with_env('REDIS_URL' => 'redis://myhost:6380/2', 'CACHE_HOST' => nil) do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://myhost:6380/2')
      end
    end

    it 'builds from CACHE_* when REDIS_URL is blank' do
      with_env(
        'REDIS_URL' => nil,
        'CACHE_AUTH_TOKEN' => nil,
        'CACHE_HOST' => 'redis',
        'CACHE_PORT' => '6379',
        'CACHE_DB' => '4',
      ) do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://redis:6379/4')
      end
    end

    it 'includes auth in URL when CACHE_AUTH_TOKEN is set' do
      with_env(
        'REDIS_URL' => nil,
        'CACHE_HOST' => 'redis',
        'CACHE_PORT' => '6379',
        'CACHE_DB' => '0',
        'CACHE_AUTH_TOKEN' => 'secret',
      ) do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://:secret@redis:6379/0')
      end
    end

    it 'falls back to localhost when neither REDIS_URL nor CACHE_HOST' do
      with_env('REDIS_URL' => nil, 'CACHE_HOST' => nil) do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://localhost:6379/1')
      end
    end
  end

  describe 'password (cache_store.yml)' do
    it 'never outputs separate password key (auth is in URL when built from CACHE_*)' do
      with_env('CACHE_AUTH_TOKEN' => 'devtoken') do
        config = load_cache_store_config
        expect(config).not_to have_key('password')
      end
    end

    it 'uses REDIS_URL as-is when set, ignoring CACHE_AUTH_TOKEN' do
      with_env('REDIS_URL' => 'redis://redis:6379/', 'CACHE_AUTH_TOKEN' => 'ignored') do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://redis:6379/')
        expect(config).not_to have_key('password')
      end
    end
  end

  describe 'URL format (config_for[:url])' do
    it 'omits auth when CACHE_AUTH_TOKEN is blank' do
      with_env(
        'REDIS_URL' => nil,
        'CACHE_HOST' => 'redis',
        'CACHE_PORT' => '6379',
        'CACHE_DB' => '0',
        'CACHE_AUTH_TOKEN' => nil,
      ) do
        config = load_cache_store_config
        expect(config['url']).to eq('redis://redis:6379/0')
      end
    end

    it 'includes auth and uses rediss when CACHE_SSL and CACHE_AUTH_TOKEN set' do
      with_env(
        'REDIS_URL' => nil,
        'CACHE_HOST' => 'redis',
        'CACHE_PORT' => '6379',
        'CACHE_DB' => '0',
        'CACHE_SSL' => 'true',
        'CACHE_AUTH_TOKEN' => 'valkey-token',
      ) do
        config = load_cache_store_config
        expect(config['url']).to eq('rediss://:valkey-token@redis:6379/0')
      end
    end
  end
end
