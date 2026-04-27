###
# Copyright 2016 - 2026 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'ostruct'

# Tree node for the site sidebar menu (ported from HMIS Warehouse).
class Menu::Item < OpenStruct
  def add_child(item)
    self.children ||= []
    return unless item.show?

    children << item
    self
  end

  def options
    {
      href: href,
      target: target,
      subject: subject,
      data: data,
    }.reject { |_, v| v.nil? }
  end

  def href
    return path if subject.blank?

    "mailto:#{path}?subject=#{subject}"
  end

  def children?
    children.present?
  end

  def icon?
    icon.present?
  end

  def group?
    group.present?
  end

  def show?
    if visible.nil?
      return children.any?(&:show?) if children?

      false
    else
      visible.call(user)
    end
  end

  def target?
    target.present?
  end

  def data?
    data.present?
  end

  def children_paths(item, paths)
    found_paths = []

    return found_paths unless item.children?

    item.children.each do |child|
      found_paths += children_paths(child, paths)

      found_paths << child.path
    end

    found_paths
  end

  def collapse_regex
    terminator = match_pattern_terminator || '\z'
    regex_parts = children_paths(self, paths).reject(&:blank?).map { |p| "^#{p}#{terminator}" }
    regex_parts << match_pattern if match_pattern.present?
    Regexp.new(regex_parts.join('|'))
  end

  def collapsed_class(path_info)
    return :show if always_open
    return :show if collapse_regex.match?(path_info.gsub("\n", '').slice(0, 500))

    :collapsed
  end
end
