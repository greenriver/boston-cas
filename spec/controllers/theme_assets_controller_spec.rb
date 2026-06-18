###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeAssetsController, type: :controller do
  before { Theme.invalidate_cache }

  describe 'GET #logo' do
    context 'when no logo is attached' do
      before { allow(Theme).to receive(:logo).and_return(Theme.active_theme.logo) }

      it 'returns 404' do
        get :logo
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when a logo is attached' do
      before do
        theme = Theme.active_theme
        theme.logo.attach(
          io: Rails.root.join('app', 'assets', 'images', 'favicon-32x32.png').open,
          filename: 'logo.png',
          content_type: 'image/png',
        )
        allow(Theme).to receive(:logo).and_return(theme.logo)
        Theme.blob_cache.clear
      end

      it 'returns 200' do
        get :logo
        expect(response).to have_http_status(:ok)
      end

      it 'serves the correct content type' do
        get :logo
        expect(response.content_type).to eq('image/png')
      end

      it 'sets a public Cache-Control header' do
        get :logo
        expect(response.headers['Cache-Control']).to include('public')
      end

      it 'caches the blob data in Theme.blob_cache' do
        expect { get :logo }.to change { Theme.blob_cache.size }.by(1)
      end

      it 'uses the cache on the second request without re-downloading' do
        get :logo
        expect(Theme.logo.blob).not_to receive(:download)
        get :logo
      end
    end
  end

  describe 'GET #favicon_32' do
    context 'when no favicon_32 is attached' do
      before { allow(Theme).to receive(:favicon_32).and_return(Theme.active_theme.favicon_32) }

      it 'returns 404' do
        get :favicon_32
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when favicon_32 is attached' do
      before do
        theme = Theme.active_theme
        theme.favicon_32.attach(
          io: StringIO.new('fake png'),
          filename: 'favicon-32x32.png',
          content_type: 'image/png',
        )
        allow(Theme).to receive(:favicon_32).and_return(theme.favicon_32)
        Theme.blob_cache.clear
      end

      it 'returns 200' do
        get :favicon_32
        expect(response).to have_http_status(:ok)
      end

      it 'serves the correct content type' do
        get :favicon_32
        expect(response.content_type).to eq('image/png')
      end
    end
  end
end
