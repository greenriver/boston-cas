###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
      routes = [['PSH Route', {}], ['RRH Route', {}]]
      allow(MatchRoutes::Base).to receive(:filterable_routes).and_return(routes)

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

    describe 'help section' do
      let(:help_record) { nil }
      let(:can_edit_help) { false }

      let(:menu_context) do
        help = help_record
        can_edit = can_edit_help

        Class.new do
          include Rails.application.routes.url_helpers

          define_method(:can_edit_help?) { can_edit }
          define_method(:help_for_path) { help }

          def help_link = nil
          def controller_path = 'application'
          def action_name = 'index'
          def can_view_reports? = false
          def can_view_opportunities? = true
          def can_view_contacts? = true
          def can_view_programs? = false
          def can_view_assigned_programs? = false
          def can_view_buildings? = false
          def can_enter_deidentified_clients? = false
          def can_enter_identified_clients? = false
          def can_manage_imported_clients? = false
          def can_manage_neighborhoods? = false
          def can_view_some_clients? = false
          def can_manage_tags? = false
          def can_view_rule_list? = false
          def can_view_available_services? = false
          def can_edit_users? = false
          def can_edit_translations? = false
          def can_view_imports? = false
          def can_administer_health? = false
          def can_view_funding_sources? = false
          def can_view_subgrantees? = false
        end.new
      end

      let(:menu_list) { described_class.new(user: user, context: menu_context).site_menu }
      let(:help_item) { menu_list.find { |i| i.id.to_s == 'help' } }

      context 'when neither can_edit_help? nor help_for_path is present' do
        it 'omits the help item from the menu' do
          expect(help_item).to be_nil
        end
      end

      context 'when a non-editor has an internal help_for_path' do
        let(:help_record) { Help.new(id: 42, location: 'internal') }

        it 'includes a leaf help item with the question icon' do
          expect(help_item).to be_present
          expect(help_item.icon).to eq('icon-question')
        end

        it 'has no children' do
          expect(help_item.children?).to be_falsey
        end

        it 'links to the internal help path' do
          expect(help_item.path).to eq('/help/42')
        end

        it 'does not set target to _blank' do
          expect(help_item.target).to be_nil
        end
      end

      context 'when a non-editor has an external help_for_path' do
        let(:help_record) { Help.new(id: 42, location: 'external', external_url: 'https://example.com/help') }

        it 'links to the external URL' do
          expect(help_item.path).to eq('https://example.com/help')
        end

        it 'sets target to _blank' do
          expect(help_item.target).to eq('_blank')
        end
      end

      context 'when an editor has no contextual help_for_path' do
        let(:can_edit_help) { true }

        it 'includes a collapsible help item with the question icon' do
          expect(help_item).to be_present
          expect(help_item.icon).to eq('icon-question')
          expect(help_item.children?).to be_truthy
        end

        it 'includes a Help Documents child' do
          expect(help_item.children.map { |c| c.title.to_s }).to include('Help Documents')
        end

        it 'includes an Add Help Here child' do
          expect(help_item.children.map { |c| c.title.to_s }).to include('Add Help Here')
        end

        it 'does not include an Edit Help child' do
          expect(help_item.children.map { |c| c.title.to_s }).not_to include('Edit Help')
        end
      end

      context 'when an editor has a contextual help_for_path' do
        let(:can_edit_help) { true }
        let(:help_record) { Help.new(id: 42, location: 'internal') }

        it 'includes an Edit Help child instead of Add Help Here' do
          titles = help_item.children.map { |c| c.title.to_s }
          expect(titles).to include('Edit Help')
          expect(titles).not_to include('Add Help Here')
        end

        it 'includes the contextual Help link as a child' do
          expect(help_item.children.map { |c| c.title.to_s }).to include('Help')
        end
      end
    end

    describe 'style guide section' do
      let(:menu_list) { described_class.new(user: user, context: menu_context).site_menu }
      let(:style_guide_item) { menu_list.find { |i| i.id.to_s == 'style-guide' } }

      context 'in the development environment' do
        before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development')) }

        it 'includes a style guide item with the pencil icon' do
          expect(style_guide_item).to be_present
          expect(style_guide_item.icon).to eq('icon-pencil')
        end

        it 'links to the style guides path' do
          expect(style_guide_item.path).to eq('/style_guides')
        end
      end

      context 'outside the development environment' do
        it 'omits the style guide item' do
          expect(style_guide_item).to be_nil
        end
      end
    end
  end
end
