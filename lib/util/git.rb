###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

require_relative 'git/release_resolver'

class Git
  def self.revision
    if Rails.env.development?
      `git rev-parse --short=9 HEAD`.chomp
    else
      File.read("#{Rails.root}/REVISION").chomp
    end
  rescue StandardError
    'unknown'
  end

  def self.branch
    if Rails.env.development?
      `git branch --no-color --show-current`.chomp
    else
      File.read("#{Rails.root}/GIT_BRANCH").chomp
    end
  rescue StandardError
    'unknown'
  end

  # Release this container is running, e.g. "v1.2.3", or "v1.2.3+4" when 4
  # commits past that tag. nil when unknown.
  def self.release
    details = release_details
    return nil if details.nil?

    tag = details[:tag]
    return nil if tag.blank?

    return tag if details[:ahead].to_i.zero?

    "#{tag}+#{details[:ahead].to_i}"
  end

  # Reads the cache file Git::ReleaseResolver writes at container start. Returns
  # { tag:, ahead: }, or nil when the file is absent, unreadable, or was computed for a
  # different commit. Memoizes nil as well as a found value.
  def self.release_details
    return nil if Rails.env.development?
    return @release_details if defined?(@release_details)

    @release_details = resolved_release_details
  end

  # Test support only.
  def self.reset_memo!
    remove_instance_variable(:@release_details) if defined?(@release_details)
  end

  def self.resolved_release_details
    path = ReleaseResolver::CACHE_PATH
    return nil unless File.exist?(path)

    details = JSON.parse(File.read(path), symbolize_names: true)
    # Ignore a cache file computed for a different commit.
    return nil unless details[:revision].to_s == revision.to_s
    return nil if details[:tag].to_s.empty?

    details
  rescue StandardError
    nil
  end
  private_class_method :resolved_release_details
end
