###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Covers Git.release / Git.release_details, ported from hmis-warehouse.
# These read the cache file written by Git::ReleaseResolver at container boot
# (lib/util/git/release_resolver.rb) — this spec only exercises the reader side.
RSpec.describe Git do
  let(:cache_path) { Git::ReleaseResolver::CACHE_PATH }
  let(:revision) { 'abc1234' }

  before do
    allow(Git).to receive(:revision).and_return(revision)
    Git.reset_memo! if Git.respond_to?(:reset_memo!)
  end

  after do
    Git.reset_memo! if Git.respond_to?(:reset_memo!)
  end

  def write_cache(tag:, ahead:, cache_revision: revision)
    allow(File).to receive(:exist?).with(cache_path).and_return(true)
    allow(File).to receive(:read).with(cache_path).and_return(
      { tag: tag, ahead: ahead, revision: cache_revision }.to_json,
    )
  end

  describe '.release' do
    it 'returns nil in development regardless of cache contents' do
      allow(Rails.env).to receive(:development?).and_return(true)
      write_cache(tag: 'v1.2.3', ahead: 0)

      expect(Git.release).to be_nil
    end

    it 'returns the bare tag when ahead is zero' do
      write_cache(tag: 'v1.2.3', ahead: 0)

      expect(Git.release).to eq('v1.2.3')
    end

    it 'returns "tag+N" when ahead of the tagged commit' do
      write_cache(tag: 'v1.2.3', ahead: 4)

      expect(Git.release).to eq('v1.2.3+4')
    end

    it 'coerces a string ahead count' do
      write_cache(tag: 'v1.2.3', ahead: '4')

      expect(Git.release).to eq('v1.2.3+4')
    end

    it 'returns nil when the cache file does not exist' do
      allow(File).to receive(:exist?).with(cache_path).and_return(false)

      expect(Git.release).to be_nil
    end

    it 'returns nil when the cache is for a different revision (stale deploy)' do
      write_cache(tag: 'v1.2.3', ahead: 0, cache_revision: 'zzz9999')

      expect(Git.release).to be_nil
    end

    it 'returns nil when the tag is empty' do
      write_cache(tag: '', ahead: 0)

      expect(Git.release).to be_nil
    end

    it 'returns nil when the cache file contains invalid JSON' do
      allow(File).to receive(:exist?).with(cache_path).and_return(true)
      allow(File).to receive(:read).with(cache_path).and_return('not json')

      expect(Git.release).to be_nil
    end

    it 'memoizes release_details so the file is only read once per process' do
      write_cache(tag: 'v1.2.3', ahead: 0)

      Git.release
      Git.release

      expect(File).to have_received(:read).with(cache_path).once
    end

    it 'memoizes a nil result too (does not re-check File.exist? on every call)' do
      allow(File).to receive(:exist?).with(cache_path).and_return(false)

      Git.release
      Git.release

      expect(File).to have_received(:exist?).with(cache_path).once
    end
  end
end
