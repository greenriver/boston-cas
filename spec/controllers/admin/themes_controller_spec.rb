###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ThemesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:role)  { create(:role, name: 'config manager', can_manage_config: true) }

  before do
    admin.roles << role
    authenticate admin
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns the theme directly from the database, bypassing the cache' do
      theme = Theme.where(client: ENV['CLIENT']).first_or_create
      get :index
      expect(assigns(:theme)).to eq(theme)
    end
  end

  describe 'PATCH #update' do
    it 'updates homepage_content and redirects to index' do
      patch :update, params: { theme: { homepage_content: '<p>Custom</p>' } }
      expect(Theme.active_theme.homepage_content).to eq('<p>Custom</p>')
      expect(response).to redirect_to(admin_themes_path)
    end

    it 'updates css and redirects to index' do
      patch :update, params: { theme: { css: 'body { color: red; }' } }
      expect(Theme.active_theme.css).to eq('body { color: red; }')
      expect(response).to redirect_to(admin_themes_path)
    end
  end

  describe 'authorization' do
    it 'blocks users without can_manage_config' do
      admin.roles.delete_all
      get :index
      expect(response).not_to render_template(:index)
    end
  end
end
