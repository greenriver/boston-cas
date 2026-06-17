###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Menu::Item do
  describe '#collapse_regex' do
    it 'does not add a leading alternation when only a match pattern is present' do
      item = described_class.new(match_pattern: 'reports', paths: [], children: [])

      expect(item.collapse_regex.source).to eq('reports')
    end

    it 'matches both child paths and the appended match pattern' do
      child = described_class.new(path: '/reports', children: [])
      item = described_class.new(children: [child], match_pattern: 'reports/\d+', paths: [])

      regex = item.collapse_regex

      expect(regex.match?('/reports')).to be_truthy
      expect(regex.match?('reports/123')).to be_truthy
    end
  end

  describe '#collapsed_class' do
    it 'matches PATH_INFO using path-only segments when child URLs include query params' do
      child = described_class.new(path: '/active_matches?current_route=PSH', children: [])
      item = described_class.new(children: [child], match_pattern_terminator: '.*')

      expect(item.collapsed_class('/active_matches')).to eq(:show)
    end

    it 'matches match_pattern for individual match pages' do
      item = described_class.new(
        match_pattern: '(?:^/matches/\d+$)',
      )

      expect(item.collapsed_class('/matches/42')).to eq(:show)
    end
  end
end
