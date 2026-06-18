###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Theme < ApplicationRecord
  has_one_attached :logo
  has_one_attached :favicon_32
  has_one_attached :favicon_16
  has_one_attached :favicon_ico

  def self.active_theme
    return @theme if @theme && @theme_cached_at && @theme_cached_at > 30.seconds.ago && !Rails.env.test?

    @theme = where(client: ENV['CLIENT']).first_or_create
    @theme_cached_at = Time.current
    @theme
  end

  def self.blob_cache
    @blob_cache ||= {}
  end

  def self.invalidate_cache
    @theme = nil
    @theme_cached_at = nil
    @blob_cache = {}
  end

  def self.logo
    theme = active_theme
    theme.set_theme_default_logo! unless theme.logo.attached?
    theme.logo
  end

  def self.favicon_32
    theme = active_theme
    theme.set_theme_default_favicons! unless theme.favicon_32.attached?
    theme.favicon_32
  end

  def self.favicon_16
    theme = active_theme
    theme.set_theme_default_favicons! unless theme.favicon_16.attached?
    theme.favicon_16
  end

  def self.favicon_ico
    theme = active_theme
    theme.set_theme_default_favicons! unless theme.favicon_ico.attached?
    theme.favicon_ico
  end

  def self.homepage_content
    active_theme.homepage_content
  end

  def set_theme_default_logo!
    return if logo.attached?

    logo_name = ENV['LOGO']
    return if logo_name.blank?

    path = Rails.root.join('app', 'assets', 'images', 'theme', 'logo', logo_name)
    found = Dir.glob("#{path}.*").first || (File.exist?(path.to_s) ? path.to_s : nil)
    return if found.blank?

    logo.attach(io: File.open(found), filename: File.basename(found))
  end

  def set_theme_default_favicons!
    icons_dir = Rails.root.join('app', 'assets', 'images', 'theme', 'icons')
    icons_fallback_dir = Rails.root.join('app', 'assets', 'images')

    unless favicon_32.attached?
      path = icons_dir.join('favicon-32x32.png')
      fallback_path = icons_fallback_dir.join('favicon-32x32.png')
      path = fallback_path if !File.exist?(path.to_s) && File.exist?(fallback_path.to_s)
      favicon_32.attach(io: File.open(path.to_s), filename: 'favicon-32x32.png') if File.exist?(path.to_s)
    end

    unless favicon_16.attached?
      path = icons_dir.join('favicon-16x16.png')
      fallback_path = icons_fallback_dir.join('favicon-16x16.png')
      path = fallback_path if !File.exist?(path.to_s) && File.exist?(fallback_path.to_s)
      favicon_16.attach(io: File.open(path.to_s), filename: 'favicon-16x16.png') if File.exist?(path.to_s)
    end

    return if favicon_ico.attached?

    path = icons_dir.join('favicon.ico')
    fallback_path = icons_fallback_dir.join('favicon.ico')
    path = fallback_path if !File.exist?(path.to_s) && File.exist?(fallback_path.to_s)
    favicon_ico.attach(io: File.open(path.to_s), filename: 'favicon.ico') if File.exist?(path.to_s)
  end

  def self.css_file_contents
    css = active_theme.css
    sanitize_css(css.presence)
  end

  def self.sanitize_css(css)
    return unless css

    css.delete('<')
  end

  after_save { self.class.invalidate_cache }
end
