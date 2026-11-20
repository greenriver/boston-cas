###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Menu::Menu do
  let(:menu_permission_helpers) do
    [
      :can_view_reports?, :can_view_opportunities?, :can_view_contacts?, :can_view_programs?,
      :can_view_assigned_programs?, :can_view_buildings?, :can_enter_deidentified_clients?,
      :can_enter_identified_clients?, :can_manage_imported_clients?, :can_manage_neighborhoods?,
      :can_view_some_clients?, :can_manage_tags?, :can_view_rule_list?, :can_view_available_services?,
      :can_edit_users?, :can_edit_roles?, :can_edit_translations?, :can_manage_config?,
      :can_manage_sessions?, :can_view_funding_sources?, :can_view_subgrantees?, :can_edit_help?
    ]
  end

  def build_menu_context(help_for_path: nil, **granted)
    values = { can_view_opportunities?: true, can_view_contacts?: true }.merge(granted)
    helpers = menu_permission_helpers

    Class.new do
      include Rails.application.routes.url_helpers

      helpers.each { |name| define_method(name) { values.fetch(name, false) } }
      define_method(:help_for_path) { help_for_path }

      def help_link = nil
      def controller_path = 'application'
      def action_name = 'index'
    end.new
  end

  describe '#site_menu' do
    before do
      routes = [['PSH Route', {}]]
      allow(MatchRoutes::Base).to receive(:filterable_routes).and_return(routes)
    end

    let(:user) { build(:user) }

    let(:menu_context) { build_menu_context }

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

    describe 'admin section' do
      let(:granted) { {} }
      let(:menu_list) { described_class.new(user: user, context: build_menu_context(**granted)).site_menu }
      let(:admin) { menu_list.find { |i| i.id.to_s == 'admin' } }
      let(:admin_titles) { admin.children.select(&:show?).to_h { |group| [group.title, group.children.select(&:show?).map(&:title)] } }

      context 'with every admin permission' do
        let(:granted) do
          {
            can_edit_users?: true, can_edit_roles?: true, can_edit_translations?: true,
            can_manage_config?: true, can_manage_tags?: true, can_manage_sessions?: true
          }
        end

        it 'is shown with the title Admin and groups in Access, Configuration, Status order' do
          expect(admin.show?).to be(true)
          expect(admin.title).to eq('Admin')
          expect(admin.children.map(&:title)).to eq(['Access', 'Configuration', 'Status'])
        end

        it 'links each admin page to its index path' do
          tree = admin.children.to_h { |group| [group.title, group.children.map { |leaf| [leaf.title, leaf.path] }] }
          expect(tree).to eq(
            'Access' => [['Users', '/admin/users'], ['Roles', '/admin/roles'], ['Agencies', '/admin/agencies']],
            'Configuration' => [
              ['Site Configuration', '/admin/configs'],
              ['Theme', '/admin/themes'],
              ['Translations', '/admin/translation_keys'],
              ['Match Routes', '/admin/match_routes'],
              ['Decline & Cancel Reasons', '/admin/match_decision_reasons'],
              ['Housing Attributes', '/admin/housing_attribute_names'],
              ['Tags', '/tags'],
            ],
            'Status' => [['Sessions', '/admin/sessions']],
          )
        end

        it 'stays expanded on nested admin pages' do
          expect(admin.collapsed_class('/admin/users/5/edit')).to eq(:show)
          expect(admin.collapsed_class('/admin/user_search_queries/1')).to eq(:show)
          expect(admin.collapsed_class('/tags/2/edit')).to eq(:show)
          expect(admin.collapsed_class('/reports')).to eq(:collapsed)
        end
      end

      context 'with only can_edit_users?' do
        let(:granted) { { can_edit_users?: true } }

        it 'shows Users and Agencies but not Roles' do
          expect(admin_titles).to eq('Access' => ['Users', 'Agencies'])
        end
      end

      context 'with only can_edit_roles?' do
        let(:granted) { { can_edit_roles?: true } }

        it 'shows only Roles' do
          expect(admin_titles).to eq('Access' => ['Roles'])
        end
      end

      context 'with only can_manage_config?' do
        let(:granted) { { can_manage_config?: true } }

        it 'shows the site configuration pages but not Translations or Tags' do
          expect(admin_titles).to eq(
            'Configuration' => ['Site Configuration', 'Theme', 'Match Routes', 'Decline & Cancel Reasons', 'Housing Attributes'],
          )
        end
      end

      context 'with only can_edit_translations?' do
        let(:granted) { { can_edit_translations?: true } }

        it 'shows only Translations' do
          expect(admin_titles).to eq('Configuration' => ['Translations'])
        end
      end

      context 'with only can_manage_sessions?' do
        let(:granted) { { can_manage_sessions?: true } }

        it 'shows only Sessions' do
          expect(admin_titles).to eq('Status' => ['Sessions'])
        end
      end

      context 'with can_manage_tags? and the inventory gate closed' do
        let(:granted) { { can_manage_tags?: true, can_view_opportunities?: false, can_view_contacts?: false } }

        it 'shows Tags under Admin' do
          expect(admin_titles).to eq('Configuration' => ['Tags'])
        end
      end

      context 'with no admin permissions' do
        it 'hides the Admin section' do
          expect(admin.show?).to be(false)
        end
      end
    end

    describe 'rules and services section' do
      let(:context) do
        build_menu_context(can_view_rule_list?: true, can_view_available_services?: true, can_manage_tags?: true)
      end
      let(:menu_list) { described_class.new(user: user, context: context).site_menu }
      let(:section) { menu_list.find { |i| i.id.to_s == 'rules-and-services' } }

      it 'is titled Rules & Services and links only to the rules and services lists' do
        expect(section.title).to eq('Rules & Services')
        expect(section.children.map { |c| [c.title, c.path] }).to eq([['Rules List', '/rules'], ['Services List', '/services']])
      end
    end

    describe 'help section' do
      let(:help_record) { nil }
      let(:can_edit_help) { false }

      let(:menu_context) { build_menu_context(help_for_path: help_record, can_edit_help?: can_edit_help) }

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
