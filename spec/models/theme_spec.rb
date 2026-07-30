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

  describe '.css_file_contents' do
    it 'returns the css string when set' do
      create(:theme, client: ENV['CLIENT'], css: 'body { color: red; }')
      expect(Theme.css_file_contents).to eq('body { color: red; }')
    end

    it 'returns nil when css is blank' do
      create(:theme, client: ENV['CLIENT'], css: nil)
      expect(Theme.css_file_contents).to be_nil
    end

    it 'returns nil when css is an empty string' do
      create(:theme, client: ENV['CLIENT'], css: '')
      expect(Theme.css_file_contents).to be_nil
    end

    it 'strips < characters to prevent </style> injection' do
      create(:theme, client: ENV['CLIENT'], css: 'body { color: red; } </style><script>alert(1)</script><style>')
      expect(Theme.css_file_contents).not_to include('<')
    end
  end

  describe '.sanitize_css' do
    it 'returns nil when passed nil' do
      expect(Theme.sanitize_css(nil)).to be_nil
    end

    it 'removes < characters from the css' do
      expect(Theme.sanitize_css('</style><script>evil</script>')).to eq('/style>script>evil/script>')
    end

    it 'leaves valid css unchanged' do
      css = "body { color: red; }\n.foo { font-size: 1rem; }"
      expect(Theme.sanitize_css(css)).to eq(css)
    end
  end

  describe 'cache invalidation' do
    it 'sets @theme to nil after save so the next call re-fetches' do
      theme = Theme.active_theme
      Theme.instance_variable_set(:@theme, theme)
      theme.update!(homepage_content: 'updated')
      expect(Theme.instance_variable_get(:@theme)).to be_nil
    end

    it 'resets @theme_cached_at after save so the next call re-fetches from the database' do
      Theme.active_theme
      Theme.instance_variable_get(:@theme).update!(homepage_content: 'updated')
      expect(Theme.instance_variable_get(:@theme_cached_at)).to be_nil
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
    it 'does nothing when neither the theme icons nor fallback files exist' do
      theme = create(:theme)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(a_string_including('favicon')).and_return(false)
      theme.set_theme_default_favicons!
      expect(theme.favicon_32.attached?).to be false
      expect(theme.favicon_16.attached?).to be false
      expect(theme.favicon_ico.attached?).to be false
    end

    it 'attaches a favicon when the file exists on disk' do
      theme = create(:theme)
      favicon_path = Rails.root.join('app', 'assets', 'images', 'theme', 'icons', 'favicon-32x32.png').to_s
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(favicon_path).and_return(true)
      fake_file = StringIO.new('fake png data')
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(favicon_path).and_return(fake_file)
      theme.set_theme_default_favicons!
      expect(theme.favicon_32.attached?).to be true
    end
  end
end
