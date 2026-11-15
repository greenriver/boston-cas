###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'application/_utility', type: :view do
  it 'escapes markup in a String flash and renders its newline as a line break' do
    flash[:notice] = "<b>x</b>\nsecond"

    render partial: 'application/utility'

    alert = Nokogiri::HTML(rendered).at_css('.alert')
    aggregate_failures do
      expect(alert.inner_html).to include('&lt;b&gt;x&lt;/b&gt;')
      expect(alert.css('b')).to be_empty
      expect(alert.css('br').size).to eq(1)
      expect(alert.text).to include('second')
    end
  end

  it 'keeps links in a SafeBuffer flash' do
    flash[:notice] = ActionController::Base.helpers.link_to('<b>x</b>', '/somewhere')

    render partial: 'application/utility'

    link = Nokogiri::HTML(rendered).at_css('.alert a[href="/somewhere"]')
    expect(link.inner_html).to eq('&lt;b&gt;x&lt;/b&gt;')
  end
end
