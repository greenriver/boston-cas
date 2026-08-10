###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownHelper, type: :helper do
  describe '#render_markdown' do
    it 'renders bold markdown as HTML' do
      expect(helper.render_markdown('**bold**')).to include('<strong>bold</strong>')
    end

    it 'renders links as anchor tags' do
      html = helper.render_markdown('[View submission](https://example.com/x)')
      expect(html).to include('<a href="https://example.com/x"')
      expect(html).to include('View submission')
    end

    it 'renders list items' do
      html = helper.render_markdown("- one\n- two")
      expect(html).to include('<li>one</li>')
      expect(html).to include('<li>two</li>')
    end

    it 'autolinks bare URLs' do
      expect(helper.render_markdown('see https://example.com')).to include('<a href="https://example.com"')
    end

    it 'returns an html_safe string' do
      expect(helper.render_markdown('**bold**')).to be_html_safe
    end

    it 'returns an empty html_safe string for blank input' do
      expect(helper.render_markdown('')).to eq('')
      expect(helper.render_markdown(nil)).to eq('')
      expect(helper.render_markdown(nil)).to be_html_safe
    end

    describe 'HTML safety' do
      it 'escapes raw HTML tags instead of rendering them' do
        html = helper.render_markdown('<script>alert(1)</script>')
        expect(html).not_to include('<script>')
        expect(html).to include('&lt;script&gt;')
      end

      it 'escapes an injected img tag so it renders as inert text, not an element' do
        html = helper.render_markdown('<img src=x onerror=alert(1)>')
        expect(html).not_to include('<img')
        expect(html).to include('&lt;img')
      end

      it 'does not emit a javascript: link from markdown link syntax' do
        html = helper.render_markdown('[click me](javascript:alert(document.cookie))')
        expect(html).not_to include('href="javascript:')
        expect(html).not_to include('<a ')
      end

      it 'does not emit an image tag from markdown image syntax' do
        html = helper.render_markdown('![pixel](https://attacker.example/track.gif)')
        expect(html).not_to include('<img')
      end
    end
  end
end
