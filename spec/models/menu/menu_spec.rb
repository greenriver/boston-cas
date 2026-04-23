###
# Copyright 2016 - 2026 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Menu::Menu do
  describe '#site_menu' do
    before do
      routes = [['PSH Route', {}]]
      allow(MatchRoutes::Base).to receive(:filterable_routes).and_return(routes)
    end

    let(:user) { build(:user) }

    let(:menu_context) do
      klass = Class.new do
        include Rails.application.routes.url_helpers

        def can_view_reports?
          false
        end

        def can_view_opportunities?
          true
        end

        def can_view_contacts?
          true
        end

        def can_view_programs?
          false
        end

        def can_view_assigned_programs?
          false
        end

        def can_view_buildings?
          false
        end

        def can_enter_deidentified_clients?
          false
        end

        def can_enter_identified_clients?
          false
        end

        def can_manage_imported_clients?
          false
        end

        def can_manage_neighborhoods?
          false
        end

        def can_view_some_clients?
          false
        end

        def can_manage_tags?
          false
        end

        def can_view_rule_list?
          false
        end

        def can_view_available_services?
          false
        end

        def can_edit_users?
          false
        end

        def can_edit_translations?
          false
        end

        def can_view_imports?
          false
        end

        def can_administer_health?
          false
        end

        def can_view_funding_sources?
          false
        end

        def can_view_subgrantees?
          false
        end

        def help_link
          nil
        end

        def help_for_path
          nil
        end

        def controller_path
          'application'
        end

        def action_name
          'index'
        end

        def can_edit_help?
          false
        end
      end

      klass.new
    end

    it 'includes a collapsible Matches section when multiple routes exist' do
      menu_list = described_class.new(user: user, context: menu_context).site_menu

      matches = menu_list.find { |i| i.show? && i.id.to_s == 'matches' }
      expect(matches).to be_present
      expect(matches.children?).to be_truthy
      expect(matches.title.to_s).to include('Matches')
    end

    it 'includes Property when inventory gate passes' do
      menu_list = described_class.new(user: user, context: menu_context).site_menu

      property = menu_list.find { |i| i.try(:show?) && i.id.to_s == 'property' }
      expect(property).to be_present
      expect(property.children?).to be_truthy
    end

    it 'always exposes Account children for signed-in helpers' do
      menu_list = described_class.new(user: user, context: menu_context).site_menu

      account = menu_list.find { |i| i.try(:show?) && i.id.to_s == 'account' }
      expect(account.children.map(&:title).join(' ')).to match(/Account|Edit|Sign/i)
    end
  end
end
