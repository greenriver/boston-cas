###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MarkdownHelper
  # Render a Markdown string to HTML, enabling HTML tags and links.
  def render_markdown(text)
    return ''.html_safe if text.blank?

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    markdown.render(text).html_safe
  end
end
