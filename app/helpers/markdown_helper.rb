###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MarkdownHelper
  # Render a trusted Markdown string to HTML.
  #
  # IMPORTANT: the result is marked html_safe, so only ever pass content
  # authored by trusted staff/admins (e.g. Translation text) here — never
  # end-user / client-entered content. The renderer is hardened as defense in
  # depth (escape_html neutralizes raw HTML tags; safe_links_only blocks
  # javascript:/data: links; no_images drops images so no remote resource
  # auto-loads as a tracking pixel), but it does NOT sanitize like an allow-list
  # would: phishing-style https links still pass through. If you ever need to
  # render untrusted input, run it through Rails' sanitize instead.
  def render_markdown(text)
    return ''.html_safe if text.blank?

    renderer = Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true, no_images: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)
    markdown.render(text).html_safe
  end
end
