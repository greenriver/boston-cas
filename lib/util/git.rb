###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

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
end
