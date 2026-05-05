###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme, type: :model do
  before { Theme.invalidate_cache }

  describe '.active_theme' do
    it 'creates a theme for the current client when none exists' do
      expect { Theme.active_theme }.to change(Theme, :count).by(1)
    end

    it 'returns the existing theme rather than creating a duplicate' do
      create(:theme, client: ENV['CLIENT'])
      expect { Theme.active_theme }.not_to change(Theme, :count)
    end

    it 'returns the theme for ENV[CLIENT]' do
      theme = create(:theme, client: ENV['CLIENT'])
      expect(Theme.active_theme).to eq(theme)
    end
  end

  describe '.homepage_content' do
    it 'returns homepage_content from the active theme' do
      create(:theme, client: ENV['CLIENT'], homepage_content: '<h1>Hello</h1>')
      expect(Theme.homepage_content).to eq('<h1>Hello</h1>')
    end

    it 'returns nil when no homepage_content is set' do
      create(:theme, client: ENV['CLIENT'])
      expect(Theme.homepage_content).to be_nil
    end
  end

  describe 'cache invalidation' do
    it 'sets @theme to nil after save so the next call re-fetches' do
      theme = Theme.active_theme
      Theme.instance_variable_set(:@theme, theme)
      theme.update!(homepage_content: 'updated')
      expect(Theme.instance_variable_get(:@theme)).to be_nil
    end
  end

  describe '#set_theme_default_logo!' do
    it 'does nothing when ENV[LOGO] is blank' do
      theme = create(:theme)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('LOGO').and_return(nil)
      theme.set_theme_default_logo!
      expect(theme.logo.attached?).to be false
    end

    it 'does nothing when the logo file does not exist on disk' do
      theme = create(:theme)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('LOGO').and_return('nonexistent_logo')
      theme.set_theme_default_logo!
      expect(theme.logo.attached?).to be false
    end
  end

  describe '#set_theme_default_favicons!' do
    it 'does nothing when the icons directory files do not exist' do
      theme = create(:theme)
      theme.set_theme_default_favicons!
      expect(theme.favicon_32.attached?).to be false
      expect(theme.favicon_16.attached?).to be false
      expect(theme.favicon_ico.attached?).to be false
    end

    it 'attaches a favicon when the file exists on disk' do
      theme = create(:theme)
      icons_dir = Rails.root.join('app', 'assets', 'images', 'theme', 'icons')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(icons_dir.join('favicon-32x32.png').to_s).and_return(true)
      allow(File).to receive(:open).and_call_original
      fake_file = StringIO.new('fake png data')
      allow(File).to receive(:open).with(icons_dir.join('favicon-32x32.png')).and_return(fake_file)
      theme.set_theme_default_favicons!
      expect(theme.favicon_32.attached?).to be true
    end
  end
end
