###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchHistoryDisplayEvent, type: :model do
  describe '#contact_display' do
    it 'shows the contact name for ungrouped events' do
      event = instance_double('MatchEvent', contact_name: 'Jane Doe')
      display_event = described_class.new(event: event)

      expect(display_event.contact_display).to eq('Jane Doe')
    end

    it 'shows "Contact Missing" when ungrouped and contact_name is blank' do
      event = instance_double('MatchEvent', contact_name: nil)
      display_event = described_class.new(event: event)

      expect(display_event.contact_display).to eq('Contact Missing')
    end

    it 'shows "1 Contact Notified" when grouped events share one contact' do
      contact = instance_double('Contact', id: 1, name: 'Alice')
      event_one = instance_double('MatchEvent', contact: contact, contact_name: 'Alice')
      event_two = instance_double('MatchEvent', contact: contact, contact_name: 'Alice')
      display_event = described_class.new(event: event_one, events: [event_one, event_two])

      expect(display_event.grouped).to be(true)
      expect(display_event.contact_display).to eq('1 Contact Notified')
    end

    it 'shows "2 Contacts Notified" for multiple contacts' do
      contact_one = instance_double('Contact', id: 1, name: 'Alice')
      contact_two = instance_double('Contact', id: 2, name: 'Bob')
      event_one = instance_double('MatchEvent', contact: contact_one, contact_name: 'Alice')
      event_two = instance_double('MatchEvent', contact: contact_two, contact_name: 'Bob')
      display_event = described_class.new(event: event_one, events: [event_one, event_two])

      expect(display_event.grouped).to be(true)
      expect(display_event.contact_display).to eq('2 Contacts Notified')
    end
  end

  describe '#contact_names' do
    it 'returns unique contact names for grouped events' do
      contact_one = instance_double('Contact', id: 1, name: 'Alice')
      contact_two = instance_double('Contact', id: 2, name: 'Bob')
      event_one = instance_double('MatchEvent', contact: contact_one)
      event_two = instance_double('MatchEvent', contact: contact_two)
      display_event = described_class.new(event: event_one, events: [event_one, event_two])

      expect(display_event.contact_names).to eq(['Alice', 'Bob'])
    end
  end
end
