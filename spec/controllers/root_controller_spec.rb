###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RootController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { authenticate user }

  describe 'GET #index' do
    context 'when Theme has a logo attached' do
      before do
        theme = Theme.active_theme
        theme.logo.attach(
          io: Rails.root.join('app', 'assets', 'images', 'favicon-32x32.png').open,
          filename: 'favicon-32x32.png',
          content_type: 'image/png',
        )
        allow(Theme).to receive(:logo).and_return(theme.logo)
      end

      it 'renders the seal-image span in the footer' do
        get :index
        expect(response.body).to include('seal-image')
      end
    end

    context 'when Theme has no logo attached' do
      before { allow(Theme).to receive(:logo).and_return(Theme.active_theme.logo) }

      it 'does not render a seal-image in the footer' do
        get :index
        expect(response.body).not_to include('seal-image')
      end
    end

    context 'when Theme has a favicon_32 attached' do
      before do
        theme = Theme.active_theme
        theme.favicon_32.attach(
          io: StringIO.new('fake png'),
          filename: 'favicon-32x32.png',
          content_type: 'image/png',
        )
        allow(Theme).to receive(:favicon_32).and_return(theme.favicon_32)
        allow(Theme).to receive(:favicon_16).and_return(Theme.active_theme.favicon_16)
        allow(Theme).to receive(:favicon_ico).and_return(Theme.active_theme.favicon_ico)
      end

      it 'renders a favicon link tag pointing to the theme assets path' do
        get :index
        expect(response.body).to include('/theme/favicon_32')
      end
    end

    context 'when Theme has no favicons attached' do
      before do
        allow(Theme).to receive(:favicon_32).and_return(Theme.active_theme.favicon_32)
        allow(Theme).to receive(:favicon_16).and_return(Theme.active_theme.favicon_16)
        allow(Theme).to receive(:favicon_ico).and_return(Theme.active_theme.favicon_ico)
      end

      it 'falls back to the default favicon' do
        get :index
        expect(response.body).to include('favicon-32x32')
      end
    end

    context 'when Theme has homepage_content' do
      before { allow(Theme).to receive(:homepage_content).and_return('<p>Custom homepage</p>') }

      it 'renders the theme homepage_content' do
        get :index
        expect(response.body).to include('Custom homepage')
      end

      it 'does not render the default fallback text' do
        get :index
        expect(response.body).not_to include('Coordinated Access matches homeless individuals')
      end
    end

    context 'when Theme has no homepage_content' do
      before { allow(Theme).to receive(:homepage_content).and_return(nil) }

      it 'renders the fallback content from _homepage_content.haml or default' do
        get :index
        expect(response.body).to include('Coordinated Access')
      end
    end
  end
end
