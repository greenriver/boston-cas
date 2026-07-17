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
  end
end
