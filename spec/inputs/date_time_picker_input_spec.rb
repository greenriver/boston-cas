###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateTimePickerInput do
  let(:model_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :scheduled_at, :datetime

      def self.name
        'TestDecision'
      end

      def self.human_attribute_name(attr, **_opts)
        attr.to_s.humanize
      end

      def self.validators_on(*)
        []
      end

      def self.reflect_on_association(*)
        nil
      end
    end
  end

  let(:model) { model_class.new }

  let(:view_context) do
    controller = ActionController::Base.new
    controller.request = ActionDispatch::TestRequest.create
    av = ActionView::Base.new(ActionController::Base.view_paths, {}, controller)
    av.extend(SimpleForm::ActionViewExtensions::FormHelper)
    av
  end

  let(:builder) { SimpleForm::FormBuilder.new(:decision, model, view_context, {}) }
  let(:html) { Capybara.string(builder.input(:scheduled_at, as: :date_time_picker, label: false)) }

  describe 'DATETIME_TD_OPTIONS' do
    subject(:options) { described_class::DATETIME_TD_OPTIONS }

    it 'enables clock, hours, and minutes components' do
      expect(options.dig(:display, :components, :clock)).to be true
      expect(options.dig(:display, :components, :hours)).to be true
      expect(options.dig(:display, :components, :minutes)).to be true
    end

    it 'enables side-by-side display' do
      expect(options.dig(:display, :sideBySide)).to be true
    end

    it 'sets 15-minute stepping' do
      expect(options[:stepping]).to eq 15
    end

    it 'uses the datetime format string' do
      expect(options.dig(:localization, :format)).to eq 'MMM d, yyyy h:mm T'
    end
  end

  describe 'rendered HTML' do
    it 'wraps the input in a datepicker controller element' do
      expect(html).to have_css('div.input-group.date.datepicker[data-controller="datepicker"]')
    end

    it 'includes the calendar toggle button' do
      expect(html).to have_css('[data-td-toggle="datetimepicker"]')
    end

    it 'serialises DATETIME_TD_OPTIONS into data-date-options' do
      node = html.find('[data-controller="datepicker"]')
      parsed = JSON.parse(node['data-date-options'])
      expect(parsed.dig('display', 'sideBySide')).to be true
      expect(parsed['stepping']).to eq 15
    end

    context 'when the attribute has an existing datetime value' do
      before { model.scheduled_at = Time.zone.local(2026, 3, 15, 14, 30) }

      it 'pre-populates the input with the formatted datetime' do
        input_value = html.find('input[type="text"]')['value']
        expect(input_value).to eq 'Mar 15, 2026 2:30 PM'
      end
    end

    context 'when the attribute is nil' do
      it 'renders an empty input' do
        input_value = html.find('input[type="text"]')['value']
        expect(input_value).to be_blank
      end
    end
  end
end
